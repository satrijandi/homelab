# TODO:
- Add claude commands
- Showcase cilium
1. Setup NewsFetch DB
2. Setup MLOps DB
3. Setup Streamzi/CDC from NewsFetch DB to Kafka and from Kafka setup a flink job to do sentiment analysis and put that back into SentimentDB
4. Setup an Airflow to do daily task fetch data from online to put into a DB.
5. Setup feast
6. Predict stock increase or not in the next 5 days
7. 





# COMMON COMMANDS:
k port-forward -n argocd svc/argocd-server 8081:80
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
k port-forward -n gitea svc/gitea-http 8082:3000
k port-forward -n mlflow svc/mlflow 8083:5000
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d