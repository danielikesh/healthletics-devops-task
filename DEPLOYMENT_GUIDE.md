# Deployment Guide — Healthletics Application

This guide explains how to deploy the Healthletics Flask app using Docker Desktop Kubernetes and Helm.

---

# 1. Requirements

- Docker Desktop (Kubernetes enabled)
- kubectl
- Helm 3
- Git

Check Kubernetes:

```bash
kubectl get nodes
```

---

# 2. Docker Image

### Build:
```bash
docker build -t xenin007/healthletics-devops:local .
```

### Run:
```bash
docker run -p 8080:8080 xenin007/healthletics-devops:local
```

### Test:
```bash
curl http://localhost:8080/health
```

CI pipeline automatically pushes images to:

```
xenin007/healthletics-devops
```

with tags like:  
`latest`, `1.0.10`

---

# 3. Helm Deployment (Manual)

Deploy:
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

Expected:
- Pod in **Running**
- Service `healthletic-app` on **8080**

---

# 4. Deployment Using deploy.sh

Run:
```bash
./scripts/deploy.sh \
  --env dev \
  --version 1.0.10 \
  --image-registry xenin007/healthletics-devops \
  --namespace default
```

The script:
- Validates input
- Ensures namespace exists
- Runs `helm lint`
- Deploys via `helm upgrade --install`
- Prints pods + services

Rollback manually:
```bash
helm rollback healthletic-app -n default
```

---

# 5. Test After Deployment

Port-forward service:
```bash
kubectl port-forward svc/healthletic-app -n default 8080:8080
```

Test endpoints:
```bash
curl http://localhost:8080/
curl http://localhost:8080/health
```

Expected:
```
DevOps Intern Task Working!
{"status":"ok"}
```

---

# 6. CI/CD Deployment Notes

### Build Stage:
- Docker build  
- Trivy scan  
- Push to Docker Hub  

### Deploy Stage (Cloud Only):
CI deploy job **cannot** connect to Docker Desktop Kubernetes because:

```
kubernetes.docker.internal:6443
```

exists ONLY on your laptop.

So:
- **Build + push** works on CI  
- **Deploy** happens using `deploy.sh` locally  

This is expected for local clusters.

---

# 7. Cleanup

Uninstall:
```bash
helm uninstall healthletic-app -n default
```

Delete namespace:
```bash
kubectl delete namespace default
```

---

# 8. Summary

You now have:

- Dockerized Flask app  
- Helm deployment  
- Local Kubernetes rollout  
- CI pipeline with scan + build + push  
- Manual deployment script  
- Health checks + rollback support  

