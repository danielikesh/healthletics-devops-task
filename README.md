# Healthletics DevOps Project

A simple Flask application deployed using Docker, Kubernetes, Helm, and GitHub Actions CI/CD.

## Features
- Python Flask app running on **8080**
- Dockerized using a lightweight Python image
- Kubernetes deployment with **Helm chart**
- Local deployment using **deploy.sh**
- CI/CD pipeline:
  - Build Docker image
  - Trivy vulnerability scan
  - Push to Docker Hub
  - (Optional) Deploy to cluster

##  Project Structure
```
.
├── app/
│   ├── app.py
│   └── requirements.txt
├── Dockerfile
├── helm/
│   └── myapp/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           └── service.yaml
├── scripts/
│   └── deploy.sh
└── .github/
    └── workflows/
        └── ci-cd-healthletics.yml
```

##  Docker Commands

Build:
```bash
docker build -t xenin007/healthletics-devops:latest .
```

Run:
```bash
docker run -p 8080:8080 xenin007/healthletics-devops:latest
```

Test:
```bash
curl http://localhost:8080/
curl http://localhost:8080/health
```

##  Kubernetes Deployment (Local)

Deploy with Helm:
```bash
helm upgrade --install healthletic-app ./helm/myapp \
  --namespace default \
  --create-namespace \
  --set image.repository=xenin007/healthletics-devops \
  --set image.tag=1.0.10 \
  --wait --timeout 300s
```

Check resources:
```bash
kubectl get pods -n default
kubectl get svc -n default
```

##  Deployment Script

Use:
```bash
./scripts/deploy.sh \
  --env dev \
  --version 1.0.10 \
  --image-registry xenin007/healthletics-devops \
  --namespace default
```

## ⚙️ CI/CD Pipeline

### Build Job:
- Login to Docker Hub  
- Build Docker image  
- Trivy scan  
- Push tags to Docker Hub  

### Deploy Job (Conceptual):
- Helm lint  
- Helm upgrade/install  
- Smoke test  
- Rollback on failure  

⚠️ Note: 
GitHub-hosted runners *cannot access* Docker Desktop Kubernetes.  
So deployment is handled locally via `deploy.sh`.

## Required GitHub Secrets
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `KUBE_CONFIG` *(base64-encoded kubeconfig)*

Generate kubeconfig secret:
```bash
cat ~/.kube/config | base64 -w0
```

##  Author
Likesh Barve  
DevOps / Cloud Engineer  
