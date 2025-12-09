# Healthletics DevOps Project

A simple Flask-based web application containerized with Docker and deployed using Helm on Kubernetes.  
This project demonstrates a complete DevOps workflow:

- Docker image build & push  
- Kubernetes deployment using Helm  
- Automated CI/CD pipeline with GitHub Actions  
- Local deployment via Docker Desktop Kubernetes  
- Health checks, probes, and rolling updates  

---

## 🚀 Features

### Application
- Python Flask app  
- `/` returns a simple message  
- `/health` returns JSON `{ "status": "ok" }`  
- Exposed on **port 8080**

### Docker
- Lightweight `python:3.11-slim` base image  
- Production-safe settings  
- Docker Hub repo: `xenin007/healthletics-devops`

### Kubernetes + Helm
- Deployment with liveness & readiness probes  
- Configurable image repository & tag  
- ClusterIP Service exposing port 8080  
- Supports rolling updates  
- Parameters stored in `values.yaml`

### CI/CD (GitHub Actions)
- Build Docker image  
- Trivy vulnerability scan  
- Push to Docker Hub  
- (Optional) Deploy using Helm  
  - Disabled by default because Docker Desktop K8s is not reachable from cloud runners  
- Local deployment handled via `deploy.sh`

---

## 📁 Project Structure

