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

##1️⃣ Basic Tool Installation

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
