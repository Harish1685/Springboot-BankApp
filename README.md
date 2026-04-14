# BankApp – Full-Stack Banking Application with DevOps, Kubernetes, GitOps, and Monitoring

## Overview:

BankApp is a hands-on project that demonstrates real-world DevOps practices by deploying a containerized Spring Boot banking application on Kubernetes. It includes CI/CD pipelines, GitOps deployment using ArgoCD, MySQL persistence, and monitoring via Prometheus and Grafana.

This project aims to bridge software development and DevOps practices, showcasing how an application flows from code to production while remaining observable and maintainable.

## Learning Goals

### By completing this project, you will learn:

**Kubernetes deployment and management:**  Pods, Deployments, StatefulSets, Services, Ingress.

**GitOps workflows:** Using ArgoCD to declaratively manage deployments.

**CI/CD pipelines:** Building, testing, and deploying Dockerized applications via GitHub Actions.

**Spring Boot application integration:** Secure authentication with Spring Security, MySQL persistence, and basic transaction operations.

**Observability & monitoring:** Using Prometheus and Grafana to monitor pods, CPU, memory, and network metrics.

**Production-like system design:** How multiple components (app, DB, monitoring) work together in Kubernetes.

**Debugging skills:** Diagnosing session issues, authentication, pod scaling, and deployment conflicts

## Architecture Diagram

## Application Stack

Below is an overview of the components, their purpose, and the technologies used in this application.

| Component             | Purpose / Technology                                                                 |
|-----------------------|---------------------------------------------------------------------------------------|
| **Backend**           | Spring Boot (Java 17)                                                                 |
| **Frontend**          | Thymeleaf / Spring MVC / Basic HTML                                                   |
| **Database**          | MySQL 8 ((StatefulSet in K8s)                                                         |
| **Containerization**  | Docker                                                                                |
| **CI/CD**             | Jenkins                                                                        |
| **Deployment**        | Kubernetes – Orchestration                                                            |
| **GitOps**            | ArgoCD – Declarative                                                                  |
| **Monitoring**        | Prometheus + Grafana (via Helm)                                                       |
| **Load Balancing / Routing** | Ingress Controller (NGINX)                                                     |   


## System Requirements

Hardware/OS:
Linux / Mac / Windows (WSL2)
4+ CPU cores, 8GB+ RAM recommended for K8s + DB + App + Monitoring

## 1️⃣ Basic Tool Installation

Install these before doing anything else.

### 1.1 Install Git
```bash
sudo apt-get update
sudo apt-get install git -y
git --version
```
Used for cloning the repository and managing code

### 1.2 Install Docker

```bash
sudo apt-get install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
docker --version
```
### 1.3 Give Docker Permission

```bash
sudo usermod -aG docker $USER
newgrp docker
```
## 1.4 Install Java

```bash
sudo apt-get install openjdk-17-jdk -y
java -version
```
### 1.5 Install kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```
### 1.6 Install Helm
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```
## 2️⃣ Kubernetes Setup (k3s)

### 2.1 Install k3s

```bash
curl -sfL https://get.k3s.io | sh -
```
### 2.2 Verify cluster

```bash
sudo kubectl get nodes
sudo kubectl get pods -A
```
### 2.3 Configure kubectl access

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes
```
Add this to .bashrc for persistence:

```bash
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
source ~/.bashrc
```
## 3️⃣ Jenkins Setup (CI/CD Server on EC2)

### 3.1 Install Jenkins

```bash
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y
```
### 3.2 Start Jenkins

```bash
sudo systemctl start jenkins
sudo systemctl enable jenkins
```
### 3.3 Access Jenkins

```bash
http://<EC2-IP>:8080
```
Unlock:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
### 3.4 Install Required Tools on Jenkins Server
```bash
sudo apt-get install docker.io -y
sudo apt-get install kubectl -y
```
## 4️⃣ Jenkins Configuration (Plugins, Tools, Security)
### 4.1 Install Required Jenkins Plugins

#### Go to:

**Manage Jenkins → Manage Plugins → Available Plugins**

### Install:

- Pipeline
- Git
- GitHub Integration
- Docker Pipeline
- Credentials Binding
- SonarQube Scanner
- Pipeline Stage View


**👉 Click:**

Install without restart

### 4.2 Restart Jenkins (Important)

After installation:
```
sudo systemctl restart jenkins
```

### 4.3 Verify Jenkins is Ready

Open:
```
http://<EC2-IP>:8080
```
**👉 Ensure:**

- Dashboard loads
- No plugin errors

## 5️⃣ Credentials Management 
  
### 5.1 Navigate to Credentials

**Manage Jenkins → Credentials → Global → Add Credentials**

### 5.2 Add Required Credentials

🔹 DockerHub Credentials
- Kind: Username & Password
- ID: docker-creds

🔹 GitHub Credentials
- Kind: Personal Access Token
- ID: github-creds

🔹 SonarQube Token (we’ll generate next)
- Kind: Secret Text
- ID: sonar-token
- 
## 6️⃣ SonarQube Setup 

### 6.1 Run SonarQube Server
```
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts
```

### 6.2 Access SonarQube
```
http://<EC2-IP>:9000
```

**Login:**

admin / admin 

👉 Change password immediately

### 6.3 Generate Sonar Token

**User → My Account → Security → Generate Token**

- Name: jenkins-token
- Copy token
- 
### 6.4 Add Token to Jenkins

**Go back to Jenkins → Credentials:**

- Kind: Secret Text
- ID: sonar-token
- Paste token
  
### 6.5 Configure SonarQube in Jenkins

Go to:

**Manage Jenkins → Configure System**

Find:

**SonarQube Servers → Add**

Fill:

- Name: sonar-server
- URL: http://<EC2-IP>:9000
- Token: sonar-token

Save.

## 7️⃣ Trivy Setup

### 7.1 Install Trivy
```
sudo apt-get install wget -y
wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.42.0_Linux-64bit.deb
sudo dpkg -i trivy_0.42.0_Linux-64bit.deb
```
### 7.2 Verify Installation
```
trivy --version
```

## 8️⃣ Global Tool Configuration

Go to:

**Manage Jenkins → Global Tool Configuration**

Configure:
🔹 Git
- Path: /usr/bin/git

🔹 Sonar Scanner
- Name: sonar-scanner
- Install automatically

## 9️⃣ ArgoCD Setup (GitOps Controller)
### 🔹 Step 1 — Install ArgoCD
```
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
### 🔹 Step 2 — Verify Installation
```
kubectl get pods -n argocd
```

👉 Wait until:

**ALL pods → Running**

⚠️ If anything is CrashLoopBackOff → stop and fix before moving ahead

### 🔹 Step 3 — Expose ArgoCD (NodePort)
```
kubectl patch svc argocd-server -n argocd -p '{
  "spec": {"type": "NodePort"}
}'
```

### 🔹 Step 4 — Get Port
```
kubectl get svc argocd-server -n argocd
```

**👉 Note the port like:**
```
443:30443
```
### 🔹 Step 5 — Access UI
```
https://<EC2-IP>:30443
```

**⚠️ Ignore SSL warning**

## 🔹 Step 6 — Get Admin Password
```
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d; echo
```

### 🔹 Step 7 — Login

- Username: admin
- Password: <above output>

## 1️⃣0️⃣ Connect ArgoCD to Repository

### 🔹 Step 8 — Add Git Repository

In ArgoCD UI:

**Settings → Repositories → Connect Repo**

Fill:

- Repo URL → <your-github-repo>
- Type → Git
- Auth → (if private use token)

### 🔹 Step 9 — Verify Connection

👉 Repo should show:
```
Status: Successful
```
## 1️⃣1️⃣ Connect ArgoCD to Cluster

👉 In your case:

**Same cluster (k3s) → already connected ✅**

Verify:
```
kubectl config current-context
```

**👉 In ArgoCD:**
```
Settings → Clusters
```

You should see:
```
in-cluster → Connected
```

## 1️⃣2️⃣ Create ArgoCD Application (Link Repo → Kubernetes)

### 🔹 Step 1 — Go to ArgoCD UI

**Applications → + NEW APP**

### 🔹 Step 2 — Fill Application Details

🔸 General
- Application Name: bankapp
- Project: default

🔸Source (VERY IMPORTANT)
- Repository URL: <your-github-repo>
- Revision: HEAD
- Path:
    k8s/

**👉 This must point to where your Kubernetes YAML files exist.**

🔸 Destination
- Cluster URL:
- https://kubernetes.default.svc
- Namespace:
    bankapp-namespace
  
🔹 Step 3 — Sync Policy

For now:

👉 Select:
```
Manual Sync
```

🔹 Step 4 — Create App

Click:
```
Create
```

Step 5 — Sync Application

Click:
```
SYNC → SYNCHRONIZE
```

**👉 What happens now:**
```
ArgoCD → reads repo → applies k8s manifests → deploys app
```

🔹 Step 6 — Verify Deployment

Check in ArgoCD UI:

You should see:

- Healthy ✅
- Synced ✅
  
Check in terminal:
```
kubectl get pods -n bankapp-namespace
```

**👉 Expect:**

- bank-app → Running
- mystatefulset → Running

### ⚠️ Important Checks
-  Replica count should be 1
-  docker image in deployment must match Jenkins build image
-  bankapp-namespace must exist

## 1️⃣3️⃣  Run Jenkins Pipeline (CI → GitOps Trigger)

**🔹 What’s already done**
- Jenkins installed & configured ✅
- Plugins + creds + Sonar + Trivy ✅
- Repo already contains Jenkinsfile ✅
- ArgoCD app already created & synced ✅
- 
### 🔹 Step 1 — Create Pipeline Job

In Jenkins:

**New Item → Pipeline → Enter name → OK**

### 🔹 Step 2 — Connect Repo

In pipeline config:

- Select: Pipeline script from SCM
- SCM: Git
- Repo URL: <your-repo>
- Credentials: github-creds
- Script Path:
    Jenkinsfile

Save.

### 🔹 Step 3 — Run Pipeline

Click:

**Build Now**

### Step 4 — What to Observe

Pipeline should execute:

**Build → Scan → Push → Update → Commit**

### 🔹 Step 5 — Verify Results
- in DockerHub the image should be pushed
- in Github deployment.yml should be updated
- In ArgoCD , **App → OutOfSync → Sync → Healthy**
- in Kubernetes , check if new pods have created or not
  

## 1️⃣4️⃣ Monitoring Setup (Prometheus + Grafana)

#### 🔹 Goal

**Observe cluster + application health in real-time**

Track:

- CPU usage
- Memory usage
- Pod health
- Restarts
  
### 🔹 Step 1 — Install Monitoring Stack (Helm)

#### Add repo
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

#### Install stack
```
helm install monitoring prometheus-community/kube-prometheus-stack \
-n monitoring --create-namespace
```

**Verify**
```
kubectl get pods -n monitoring
```

👉 Wait until:

**All pods → Running**

### 🔹 Step 2 — Access Grafana

#### Expose Grafana
```
kubectl patch svc monitoring-grafana -n monitoring -p '{
  "spec": {"type": "NodePort"}
}'
```
#### Get port
```
kubectl get svc monitoring-grafana -n monitoring
```

#### Open in browser
```
http://<EC2-IP>:<NODEPORT>
```

#### Get login password
```
kubectl get secret monitoring-grafana -n monitoring \
-o jsonpath="{.data.admin-password}" | base64 -d
```
**Login**

- Username: admin
- Password: <above>

### 🔹 Step 3 — View Dashboards

Go to:
```
Dashboards → Browse
```

Use:
```
Kubernetes / Compute Resources / Pod
```

🔹 Select your app
- Namespace: bankapp-namespace
- Pod: bank-app-*
  
#### What to Observe

- CPU usage
- Memory usage
- Pod restarts
- Network usage

## 1️⃣5️⃣  Final Stage — Project Completion Checklist

Before closing, confirm these:

- App runs via ArgoCD ✅
- Pipeline builds & updates image ✅
- GitOps sync works ✅
- Monitoring dashboards visible ✅
- Jenkins + Sonar + Trivy integrated ✅

## 1️⃣6️⃣ Final Flow Summary 
```
Developer → Git Push
        ↓
     Jenkins (CI)
        ↓
Build + Scan + Push Image
        ↓
Update Kubernetes Manifest (Git)
        ↓
ArgoCD detects change
        ↓
Deploys to Kubernetes
        ↓
Prometheus collects metrics
        ↓
Grafana visualizes system health
```

## 1️⃣7️⃣Key Learnings

- Implemented end-to-end CI/CD pipeline using Jenkins
- Used GitOps (ArgoCD) for declarative deployments
- Deployed stateful and stateless apps on Kubernetes (k3s)
- Integrated monitoring using Prometheus and Grafana
- Implemented security scanning using Trivy
- Solved real-world issues like session handling in multi-pod setup

## 1️⃣8️⃣ Future Improvements (Short, clean)

- Add Dev/Prod environments 
- Implement alerting (Grafana/Prometheus)
- Use Ingress with domain + TLS

