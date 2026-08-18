# Lab 06 – Kubernetes Fundamentals with Minikube

#Student Information

Name: Devon Preminga
NO: CIT-24-01-0137
Module: CCS3308 – Virtualization and Containers
Lab: Week 7 – Container Orchestration & Kubernetes

#Project Overview

This lab demonstrates the use of Kubernetes to deploy and manage a multi-container application using Minikube.

The application consists of four tiers:

```text
Frontend
   │
   ▼
API
   │
   ├── Cache
   │
   └── Database
```

The application uses the following Docker images:

| Tier     | Docker Image         | Port | Kubernetes Resource         |
| -------- | -------------------- | ---: | --------------------------- |
| Frontend | nginx                |   80 | Pod / Deployment / Service  |
| API      | kennethreitz/httpbin |   80 | Deployment / Service        |
| Cache    | redis:7-alpine       | 6379 | Deployment / Service        |
| Database | postgres:16-alpine   | 5432 | StatefulSet / PVC / Service |

#Prerequisites

The following software is required:

* Docker
* kubectl
* Minikube

Start the Minikube cluster using:

```bash
minikube start --driver=docker
```

Verify that the cluster is running:

```bash
kubectl get nodes
```

#Project Structure

```text
lab6/
├── k8s/
│   ├── pod-frontend.yaml
│   ├── deployment-frontend.yaml
│   ├── service-frontend.yaml
│   ├── api-deployment.yaml
│   ├── api-service.yaml
│   ├── cache-deployment.yaml
│   ├── cache-service.yaml
│   ├── postgres-statefulset.yaml
│   └── postgres-service.yaml
│
├── screenshots/
├── answers.md
└── README.md
```

## Deployment Instructions

### 1. Deploy the Frontend

```bash
kubectl apply -f k8s/deployment-frontend.yaml
kubectl apply -f k8s/service-frontend.yaml
```

Check the deployment:

```bash
kubectl get deployments
kubectl get pods
kubectl get services
```

Access the frontend:

```bash
minikube service frontend --url
```

### 2. Deploy the API

```bash
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/api-service.yaml
```

### 3. Deploy the Cache

```bash
kubectl apply -f k8s/cache-deployment.yaml
kubectl apply -f k8s/cache-service.yaml
```

### 4. Deploy PostgreSQL

```bash
kubectl apply -f k8s/postgres-service.yaml
kubectl apply -f k8s/postgres-statefulset.yaml
```

## Verify the Application

Run:

```bash
kubectl get all
```

Check persistent storage:

```bash
kubectl get pvc
```

## Features Demonstrated

This lab demonstrates:

* Kubernetes Pods
* Deployments and replica management
* Self-healing
* Scaling applications
* Services and networking
* Rolling updates
* Rollbacks
* Multi-container application deployment
* StatefulSets
* Persistent storage using PersistentVolumeClaims
* Internal service connectivity
* Basic monitoring and troubleshooting

## Cleanup

Remove all Kubernetes resources:

```bash
kubectl delete -f k8s/
```

Verify that the resources have been removed:

```bash
kubectl get all
```

Stop Minikube:

```bash
minikube stop
```

## Checkpoint Answers

The answers to the nine checkpoint questions can be found in:

```text
answers.md
```
