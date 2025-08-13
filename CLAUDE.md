# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a Kubernetes deployment repository for the OrgFin application, which consists of a multi-service architecture:

- **Backend Services**:
  - `orgfin-backend` (Python/FastAPI): Main API service running on port 8000
  - `orgfin-backend-go` (Go): Secondary API service running on port 8001  
  - `orgfin-celery`: Background task processor
  - `orgfin-beat`: Task scheduler
  - `redis`: Caching and message broker

- **Frontend**: 
  - `orgfin-frontend`: Web application running on port 80

## Deployment Commands

### Production Deployment
```bash
# Deploy backend services
cd orgfin-backend && ./apply.sh

# Deploy frontend
cd orgfin-frontend && ./apply.sh
```

### Manual Kubernetes Operations
```bash
# Apply specific environment
kubectl apply -k orgfin-backend/overlays/prod
kubectl apply -k orgfin-backend/overlays/dev
kubectl apply -k orgfin-frontend/overlays/prod
kubectl apply -k orgfin-frontend/overlays/dev

# View resources
kubectl get deployments
kubectl get services
kubectl get ingresses
```

## Environment Configuration

- **Production**: Uses `.env.prod` files in overlay directories
- **Development**: Uses `.env` files in overlay directories
- Environment variables are managed through Kustomize ConfigMaps
- The `HOSTNAME` variable is automatically replaced in Ingress configurations

## Kustomize Structure

The repository uses Kustomize for Kubernetes resource management:

- `base/`: Base Kubernetes manifests
- `overlays/dev/`: Development-specific patches and configurations
- `overlays/prod/`: Production-specific patches and configurations

Key patches applied in overlays:
- Environment-specific ConfigMap generation
- Ingress hostname replacement based on environment
- Command overrides for development (e.g., gunicorn configuration)

## Docker Images

The deployments reference Docker images from Docker Hub:
- `ypeskov/api-orgfin`: Python backend API
- `ypeskov/api-go-orgfin`: Go backend API  
- `ypeskov/frontend-orgfin`: Frontend application

Image versions are managed directly in deployment YAML files and should be updated there for releases.