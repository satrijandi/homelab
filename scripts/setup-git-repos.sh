#!/bin/bash

set -e

GITHUB_REPO="https://github.com/satrijandi/homelab.git"
GITEA_USER="admin"
GITEA_PASS="homelab123"
GITEA_ORG="ops"
GITEA_REPO="homelab"

# Function to check if Gitea is accessible
check_gitea_accessible() {
    # Try to access Gitea via NodePort
    if curl -f -s http://localhost:30300/api/healthz >/dev/null 2>&1; then
        return 0
    fi
    
    # Try via cluster IP if NodePort fails
    GITEA_IP=$(kubectl get svc gitea-http -n gitea -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
    if [[ -n "$GITEA_IP" ]] && kubectl exec -n gitea deployment/gitea -- curl -f -s http://$GITEA_IP:3000/api/healthz >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Function to check if ops/homelab repository exists in Gitea
check_gitea_repo_exists() {
    if ! check_gitea_accessible; then
        return 1
    fi
    
    # Check via API
    if curl -f -s -u "$GITEA_USER:$GITEA_PASS" http://localhost:30300/api/v1/repos/$GITEA_ORG/$GITEA_REPO >/dev/null 2>&1; then
        return 0
    fi
    
    # If NodePort fails, try via port-forward
    kubectl port-forward -n gitea svc/gitea-http 13000:3000 >/dev/null 2>&1 &
    PF_PID=$!
    sleep 3
    
    if curl -f -s -u "$GITEA_USER:$GITEA_PASS" http://localhost:13000/api/v1/repos/$GITEA_ORG/$GITEA_REPO >/dev/null 2>&1; then
        kill $PF_PID 2>/dev/null || true
        return 0
    fi
    
    kill $PF_PID 2>/dev/null || true
    return 1
}

# Function to create organization and repository in Gitea
create_gitea_repo() {
    echo "Creating Gitea repository..."
    
    # Port forward to Gitea
    kubectl port-forward -n gitea svc/gitea-http 13000:3000 >/dev/null 2>&1 &
    PF_PID=$!
    sleep 5
    
    # Create organization if it doesn't exist
    curl -X POST -s -u "$GITEA_USER:$GITEA_PASS" \
         -H "Content-Type: application/json" \
         -d "{\"username\": \"$GITEA_ORG\", \"full_name\": \"Operations\"}" \
         http://localhost:13000/api/v1/orgs 2>/dev/null || true
    
    # Create repository
    curl -X POST -s -u "$GITEA_USER:$GITEA_PASS" \
         -H "Content-Type: application/json" \
         -d "{\"name\": \"$GITEA_REPO\", \"description\": \"Homelab GitOps Repository\", \"private\": false}" \
         http://localhost:13000/api/v1/orgs/$GITEA_ORG/repos
    
    kill $PF_PID 2>/dev/null || true
    echo "Repository created in Gitea"
}

# Function to get the appropriate Git repository URL
get_repo_url() {
    if check_gitea_repo_exists; then
        echo "http://gitea-http.gitea.svc.cluster.local:3000/$GITEA_ORG/$GITEA_REPO.git"
    else
        echo "$GITHUB_REPO"
    fi
}

# Function to push to both repositories
push_to_repos() {
    echo "Pushing to GitHub..."
    git push origin main || git push github main
    
    if check_gitea_accessible; then
        if ! check_gitea_repo_exists; then
            create_gitea_repo
            sleep 2
        fi
        
        echo "Pushing to Gitea..."
        # Remove existing gitea remote if it exists
        git remote remove gitea 2>/dev/null || true
        
        # Add gitea remote (try NodePort first, then port-forward)
        if curl -f -s http://localhost:30300/api/healthz >/dev/null 2>&1; then
            git remote add gitea http://$GITEA_USER:$GITEA_PASS@localhost:30300/$GITEA_ORG/$GITEA_REPO.git
        else
            # Use port-forward
            kubectl port-forward -n gitea svc/gitea-http 13000:3000 >/dev/null 2>&1 &
            PF_PID=$!
            sleep 3
            git remote add gitea http://$GITEA_USER:$GITEA_PASS@localhost:13000/$GITEA_ORG/$GITEA_REPO.git
        fi
        
        git push gitea main --force
        [[ -n "${PF_PID:-}" ]] && kill $PF_PID 2>/dev/null || true
        echo "Pushed to Gitea"
    else
        echo "Gitea not accessible, skipping Gitea push"
    fi
}

# Main execution
case "${1:-}" in
    "check-gitea")
        if check_gitea_accessible; then
            echo "accessible"
        else
            echo "not-accessible"
        fi
        ;;
    "check-repo")
        if check_gitea_repo_exists; then
            echo "exists"
        else
            echo "not-exists"
        fi
        ;;
    "get-repo-url")
        get_repo_url
        ;;
    "push")
        push_to_repos
        ;;
    *)
        echo "Usage: $0 {check-gitea|check-repo|get-repo-url|push}"
        exit 1
        ;;
esac