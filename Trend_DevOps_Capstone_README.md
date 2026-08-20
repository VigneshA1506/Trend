# Trend Application -- AWS DevOps Capstone Project

## 1. Project Overview

This project demonstrates an end-to-end DevOps implementation for
deploying the **Trend** web application using AWS, Docker, Jenkins,
Kubernetes, Terraform, GitHub, DockerHub, Prometheus, and Grafana.

### End-to-End Flow

``` text
GitHub → Jenkins → Docker Build → DockerHub → AWS EKS → Kubernetes → LoadBalancer → Trend Application
                                      |
                                      +→ Prometheus → Grafana
```

## 2. Objectives

-   Deploy the Trend application in a production-style environment.
-   Dockerize the application.
-   Push the Docker image to DockerHub.
-   Provision AWS infrastructure using Terraform.
-   Configure Jenkins CI/CD.
-   Deploy the application to AWS EKS using Kubernetes.
-   Expose the application through a Kubernetes LoadBalancer.
-   Implement monitoring using Prometheus and Grafana.
-   Maintain DevOps configuration in GitHub.

## 3. Technologies Used

  Technology          Purpose
  ------------------- ---------------------------------
  Git                 Version control
  GitHub              Source repository
  Docker              Containerization
  DockerHub           Container registry
  Terraform           AWS infrastructure provisioning
  AWS EC2             Jenkins and DevOps tools
  AWS VPC             Network infrastructure
  AWS EKS             Kubernetes platform
  Kubernetes          Container orchestration
  Jenkins             CI/CD automation
  Prometheus          Monitoring
  Grafana             Monitoring visualization
  Nginx               Web server
  Amazon Linux 2023   EC2 operating system

## 4. GitHub Repository

Repository:

`https://github.com/VigneshA1506/Trend`

Project structure:

``` text
Trend/
├── Dockerfile
├── Jenkinsfile
├── README.md
├── dist/
├── k8s/
│   ├── deployment.yaml
│   └── service.yaml
└── monitoring/
    ├── prometheus-config.yaml
    ├── prometheus-rbac.yaml
    ├── prometheus-deployment.yaml
    ├── prometheus-service.yaml
    ├── grafana-deployment.yaml
    └── grafana-service.yaml
```

## 5. Application

The provided Trend application contains a production-ready static build
in the `dist` directory.

It was first tested locally and then containerized using Docker.

Local testing example:

``` bash
cd dist
python -m http.server 3000
```

Application:

`http://localhost:3000`

## 6. Dockerization

Dockerfile:

``` dockerfile
FROM nginx:alpine

COPY dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Dockerfile Explanation

-   `FROM nginx:alpine` -- uses a lightweight Nginx image.
-   `COPY dist /usr/share/nginx/html` -- copies the production build
    into the Nginx web root.
-   `EXPOSE 80` -- documents the container web port.
-   `CMD` -- starts Nginx in the foreground.

Build:

``` bash
docker build -t trend-app .
```

Run locally:

``` bash
docker run -d -p 3000:80 --name trend-container trend-app
```

Application:

`http://localhost:3000`

## 7. DockerHub

DockerHub repository:

`vickyamav/trend-app`

Image:

``` text
vickyamav/trend-app:latest
```

Tag:

``` bash
docker tag trend-app vickyamav/trend-app:latest
```

Push:

``` bash
docker push vickyamav/trend-app:latest
```

## 8. Terraform Infrastructure

Terraform was used to provision the initial AWS infrastructure in:

``` text
ap-south-1 (Mumbai)
```

Resources included:

-   VPC
-   Public subnet
-   Internet Gateway
-   Route table
-   Route table association
-   Security Group
-   EC2 instance

Architecture:

``` text
AWS Mumbai
   |
   v
VPC
   |
   +-- Public Subnet
   |
   +-- Internet Gateway
   |
   +-- Route Table
   |
   +-- Security Group
   |
   +-- EC2 / Jenkins
```

### Terraform Commands

``` bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

State verification:

``` bash
terraform state list
```

## 9. AWS EC2

Amazon Linux 2023 was used for the DevOps server.

Tools configured on the EC2 instance:

-   Docker
-   Git
-   AWS CLI
-   kubectl
-   Jenkins

Jenkins was configured on port `8080`.

## 10. Docker on EC2

Docker was installed and enabled using:

``` bash
sudo dnf update -y
sudo dnf install docker -y
sudo systemctl start docker
sudo systemctl enable docker
```

Verification:

``` bash
docker --version
docker ps
```

Docker access was configured for the EC2 user and Jenkins.

## 11. Jenkins

Jenkins was installed on Amazon Linux 2023 using Java 21 and the Jenkins
RPM repository.

Jenkins was accessed through:

``` text
http://<EC2-Public-IP>:8080
```

Initial password:

``` bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Jenkins capabilities/plugins

-   Git
-   GitHub
-   Pipeline
-   Docker Pipeline
-   Credentials Binding
-   Kubernetes
-   GitHub API
-   Pipeline: Stage View

## 12. Jenkins Credentials

DockerHub credentials were stored in Jenkins using:

``` text
Credential ID: dockerhub-credentials
```

Credentials were injected into the pipeline using Jenkins Credentials
Binding rather than hardcoding passwords.

## 13. Jenkins Pipeline

The pipeline contains the following stages:

``` text
Checkout
   ↓
Docker Build
   ↓
DockerHub Push
   ↓
Kubernetes Deploy
```

Major activities:

1.  Checkout source from GitHub.
2.  Build Docker image.
3.  Authenticate securely to DockerHub.
4.  Tag the image.
5.  Push the image.
6.  Deploy to EKS using Kubernetes.

## 14. GitHub Webhook

A GitHub webhook was configured to trigger Jenkins when changes are
pushed to the `main` branch.

Webhook pattern:

``` text
http://<JENKINS-PUBLIC-IP>:8080/github-webhook/
```

Jenkins trigger:

``` text
GitHub hook trigger for GITScm polling
```

Therefore:

``` text
Git Push → GitHub → Webhook → Jenkins → Pipeline
```

## 15. AWS EKS

EKS cluster:

``` text
trend-eks-cluster
```

Region:

``` text
ap-south-1
```

The EKS cluster was configured with a managed node group.

Node verification:

``` bash
kubectl get nodes
```

The worker node was verified in `Ready` state.

## 16. Kubernetes Deployment

File:

``` text
k8s/deployment.yaml
```

Deployment:

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trend-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: trend-app
  template:
    metadata:
      labels:
        app: trend-app
    spec:
      containers:
        - name: trend-app
          image: vickyamav/trend-app:latest
          ports:
            - containerPort: 80
```

Apply:

``` bash
kubectl apply -f k8s/deployment.yaml
```

Verify:

``` bash
kubectl get deployments
kubectl get pods
```

## 17. Kubernetes Service

File:

``` text
k8s/service.yaml
```

Service:

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: trend-service
spec:
  type: LoadBalancer
  selector:
    app: trend-app
  ports:
    - port: 80
      targetPort: 80
```

Apply:

``` bash
kubectl apply -f k8s/service.yaml
```

Verify:

``` bash
kubectl get svc
```

The Trend application was successfully exposed through an AWS
LoadBalancer.

## 18. Kubernetes Verification

Commands used:

``` bash
kubectl get nodes
kubectl get pods
kubectl get deployments
kubectl get svc
```

Expected application pod state:

``` text
READY: 1/1
STATUS: Running
RESTARTS: 0
```

## 19. Prometheus Monitoring

Prometheus was deployed inside EKS using Kubernetes YAML files without
Helm.

Resources included Prometheus configuration, RBAC, Deployment and
Service.

Example:

``` bash
kubectl apply -f monitoring/prometheus-rbac.yaml
kubectl apply -f monitoring/prometheus-config.yaml
kubectl apply -f monitoring/prometheus-deployment.yaml
kubectl apply -f monitoring/prometheus-service.yaml
```

Verification:

``` bash
kubectl get pods
```

Prometheus was successfully deployed in the EKS cluster.

## 20. Grafana Monitoring

Grafana was deployed manually using Kubernetes YAML files without Helm.

``` bash
kubectl apply -f monitoring/grafana-deployment.yaml
kubectl apply -f monitoring/grafana-service.yaml
```

Verification:

``` bash
kubectl get pods
kubectl get svc grafana
```

Grafana was successfully exposed using a Kubernetes LoadBalancer and
accessed through the browser.

## 21. Monitoring Architecture

``` text
AWS EKS
   |
   +-- Trend Application
   |
   +-- Prometheus
          |
          v
       Grafana
          |
          v
    Monitoring UI
```

## 22. Complete CI/CD Flow

### Step 1 -- GitHub

Developer pushes changes:

``` bash
git add .
git commit -m "Update application"
git push origin main
```

### Step 2 -- GitHub Webhook

GitHub triggers Jenkins.

### Step 3 -- Jenkins Checkout

Jenkins retrieves the latest source.

### Step 4 -- Docker Build

``` bash
docker build -t trend-app .
```

### Step 5 -- DockerHub Push

The image is tagged and pushed as:

``` text
vickyamav/trend-app:latest
```

### Step 6 -- Kubernetes Deployment

Jenkins deploys the application to EKS.

### Step 7 -- LoadBalancer

Kubernetes exposes the application through an AWS LoadBalancer.

### Step 8 -- Monitoring

Prometheus and Grafana provide monitoring and visualization.

## 23. Final Architecture

``` text
                         GitHub
                           |
                           | Webhook
                           v
                     +-----------+
                     |  Jenkins  |
                     +-----------+
                           |
                 +---------+---------+
                 |                   |
                 v                   v
          Docker Build        DockerHub Push
                 |                   |
                 +---------+---------+
                           |
                           v
                    AWS EKS Cluster
                           |
              +------------+------------+
              |                         |
              v                         v
       Trend Deployment           Monitoring
              |                    /                      v                   v          v
       Trend Service         Prometheus    Grafana
              |
              v
       AWS LoadBalancer
              |
              v
       Trend Web Application
```

## 24. Verification Checklist

  Component               Status
  ----------------------- --------------
  GitHub Repository       Completed
  Dockerfile              Completed
  Docker Image            Completed
  DockerHub Repository    Completed
  Terraform VPC           Completed
  Terraform Subnet        Completed
  Internet Gateway        Completed
  Route Table             Completed
  Security Group          Completed
  Jenkins                 Completed
  Jenkins Pipeline        Completed
  GitHub Webhook          Configured
  DockerHub Push          Completed
  EKS Cluster             Completed
  EKS Node                Ready
  Kubernetes Deployment   Running
  Kubernetes Service      LoadBalancer
  Trend Application       Accessible
  Prometheus              Running
  Grafana                 Running
  Monitoring              Implemented

## 25. Suggested Submission Screenshots

Attach the following screenshots as evidence:

1.  Terraform initialization/plan.
2.  AWS VPC and subnet.
3.  EC2 instance.
4.  Security Group.
5.  Docker image.
6.  DockerHub repository.
7.  GitHub repository.
8.  Jenkins dashboard.
9.  Jenkins Stage View.
10. Successful Jenkins pipeline.
11. EKS cluster.
12. EKS node in Ready state.
13. Kubernetes pods.
14. Kubernetes LoadBalancer service.
15. Trend application through LoadBalancer.
16. Prometheus pod.
17. Grafana pod.
18. Grafana monitoring screen.

## 26. Project Outcome

The Trend application was successfully:

-   Version controlled using GitHub.
-   Containerized using Docker.
-   Stored in DockerHub.
-   Integrated with Jenkins CI/CD.
-   Deployed to AWS EKS using Kubernetes.
-   Exposed through an AWS LoadBalancer.
-   Integrated with Prometheus and Grafana monitoring.

The project demonstrates the complete DevOps lifecycle:

``` text
Version Control
      ↓
Continuous Integration
      ↓
Containerization
      ↓
Container Registry
      ↓
Continuous Deployment
      ↓
Kubernetes
      ↓
Cloud Load Balancing
      ↓
Monitoring
```

## 27. Conclusion

This project demonstrates an end-to-end DevOps implementation using AWS
and open-source DevOps tools. Source changes flow from GitHub through
Jenkins, Docker and DockerHub into AWS EKS, where the Trend application
is deployed using Kubernetes and exposed through a LoadBalancer.
Prometheus and Grafana provide the monitoring layer.

**Project status: Completed for submission.**
