# 📘 Microservices Project – README

## 1. Overview
This project contains microservices upgraded from:
- **Java JDK 8 → JDK 17**
- **Cloud Foundry → AWS EKS**

We are using:
- **Docker** for containerization
- **Jenkins pipeline** for CI/CD
- **AWS EKS** for deployment

---

## 2. Prerequisites
- Java 17 (runtime & build)
- Docker (with access to image registry)
- kubectl & Helm (if Helm charts are used)
- AWS CLI (configured with cluster access)
- Jenkins (pipeline setup)

---

## 3. Project Structure
- `src/` – Application source code
- `Dockerfile` – Container build definition
- `Jenkinsfile` – CI/CD pipeline script
- `k8s/` – Kubernetes manifests (Deployment, Service, ConfigMaps, etc.)
- `helm/` *(if applicable)* – Helm chart for deployment

---

## 4. Build & Run Locally
```bash
# Build
./mvnw clean package -DskipTests

# Run locally
java -jar target/app.jar
```

---

## 5. Docker Build & Run
```bash
# Build image
docker build -t <registry>/<service-name>:<tag> .

# Run container locally
docker run -p 8080:8080 <registry>/<service-name>:<tag>
```

---

## 6. CI/CD with Jenkins
- **Build Stage**
  - Compile & test using JDK 17
  - Package JAR
  - Build Docker image
  - Push to registry

- **Deploy Stage**
  - Apply Kubernetes manifests (or Helm chart) to EKS
  - Rollout restart if update

---

## 7. Deployment on AWS EKS
```bash
# Verify cluster access
aws eks update-kubeconfig --region <region> --name <cluster-name>
kubectl get nodes

# Deploy microservice
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## 8. Configuration
- Environment variables (e.g., `DB_URL`, `REDIS_HOST`)
- Secrets management (via AWS Secrets Manager or K8s Secrets)
- Logging & monitoring (CloudWatch, Prometheus, etc.)

---

## 9. Migration Notes
- **Java**: Updated source & dependencies to support JDK 17
- **Cloud Foundry → EKS**: replaced `manifest.yml` with Kubernetes manifests
- **Build**: switched from CF push to Docker + Jenkins pipeline

---

## 10. Troubleshooting
- JDK version mismatch → Ensure Java 17 is installed
- Docker build errors → Check Dockerfile syntax & base image
- Jenkins pipeline failures → Review Jenkins logs
- Deployment issues → Validate Kubernetes manifests & AWS permissions

---

## 11. References
- [AWS EKS Docs](https://docs.aws.amazon.com/eks/)
- [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)
- [Docker Docs](https://docs.docker.com/)
- [Java 17 Features](https://openjdk.org/projects/jdk/17/)