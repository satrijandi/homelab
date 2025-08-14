package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"time"

	"code.gitea.io/sdk/gitea"
	"gopkg.in/yaml.v2"
)

type Config struct {
	Organizations []Organization `yaml:"organizations"`
	Repositories  []Repository   `yaml:"repositories"`
}

type Organization struct {
	Name        string `yaml:"name"`
	Description string `yaml:"description"`
	Teams       []Team `yaml:"teams"`
}

type Team struct {
	Name    string   `yaml:"name"`
	Members []string `yaml:"members"`
}

type Repository struct {
	Name    string  `yaml:"name"`
	Owner   string  `yaml:"owner"`
	Private bool    `yaml:"private"`
	Migrate Migrate `yaml:"migrate"`
}

type Migrate struct {
	Source string `yaml:"source"`
	Mirror bool   `yaml:"mirror"`
}

func main() {
	giteaURL := os.Getenv("GITEA_URL")
	if giteaURL == "" {
		giteaURL = "http://gitea-http:3000"
	}

	adminUser := os.Getenv("GITEA_ADMIN_USERNAME")
	if adminUser == "" {
		adminUser = "admin"
	}

	adminPassword := os.Getenv("GITEA_ADMIN_PASSWORD")
	if adminPassword == "" {
		log.Fatal("GITEA_ADMIN_PASSWORD environment variable is required")
	}

	// Wait for Gitea to be ready
	client, err := gitea.NewClient(giteaURL, gitea.SetBasicAuth(adminUser, adminPassword))
	if err != nil {
		log.Fatal(err)
	}

	// Wait for Gitea to be available
	for i := 0; i < 60; i++ {
		_, _, err := client.GetMyUserInfo()
		if err == nil {
			break
		}
		log.Printf("Waiting for Gitea to be ready... (%d/60)", i+1)
		time.Sleep(5 * time.Second)
	}

	// Read configuration
	configData, err := ioutil.ReadFile("/config/config.yaml")
	if err != nil {
		log.Fatal(err)
	}

	var config Config
	err = yaml.Unmarshal(configData, &config)
	if err != nil {
		log.Fatal(err)
	}

	// Create organizations
	for _, org := range config.Organizations {
		_, _, err := client.CreateOrg(gitea.CreateOrgOption{
			Name:        org.Name,
			Description: org.Description,
		})
		if err != nil {
			log.Printf("Organization %s may already exist: %v", org.Name, err)
		} else {
			log.Printf("Created organization: %s", org.Name)
		}
	}

	// Migrate repositories
	for _, repo := range config.Repositories {
		existing, _, _ := client.GetRepo(repo.Owner, repo.Name)
		if existing != nil {
			log.Printf("Repository %s/%s already exists, skipping migration", repo.Owner, repo.Name)
			continue
		}

		_, _, err := client.MigrateRepo(gitea.MigrateRepoOption{
			RepoName:    repo.Name,
			RepoOwner:   repo.Owner,
			CloneAddr:   repo.Migrate.Source,
			Mirror:      repo.Migrate.Mirror,
			Private:     repo.Private,
			Description: fmt.Sprintf("Migrated from %s", repo.Migrate.Source),
		})
		if err != nil {
			log.Printf("Failed to migrate repository %s: %v", repo.Name, err)
		} else {
			log.Printf("Migrated repository: %s/%s", repo.Owner, repo.Name)
		}
	}

	log.Println("Gitea configuration completed")
}