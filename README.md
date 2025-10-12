# OrgFin Kubernetes Deployment

Kubernetes deployment configuration for the OrgFin application - a multi-service financial organization platform.

## Architecture

The application consists of the following services:

### Backend Services
- **orgfin-backend** (Python/FastAPI) - Main API service (port 8000)
- **orgfin-backend-go** (Go) - Secondary API service (port 8001)
- **orgfin-celery** - Background task processor
- **orgfin-beat** - Task scheduler
- **redis** - Caching and message broker

### Frontend
- **orgfin-frontend** - Web application (port 80)

## Prerequisites

- `kubectl` installed and configured
- `kustomize` (or kubectl v1.14+)
- Access to Kubernetes cluster
- Docker images available:
  - `ypeskov/api-orgfin`
  - `ypeskov/api-go-orgfin`
  - `ypeskov/frontend-orgfin`

## Quick Start

### Deploy to Production

```bash
# Backend services
cd orgfin-backend
./apply.sh

# Frontend
cd orgfin-frontend
./apply.sh
```

### Deploy to Development

```bash
# Backend
kubectl apply -k orgfin-backend/overlays/dev

# Frontend
kubectl apply -k orgfin-frontend/overlays/dev
```

## Directory Structure

```
.
├── orgfin-backend/
│   ├── base/                  # Base Kubernetes manifests
│   │   ├── deployment.yaml    # Backend deployments
│   │   ├── service.yaml       # Services configuration
│   │   ├── ingress.yaml       # Ingress rules
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/               # Development environment
│       │   ├── .env           # Dev environment variables
│       │   └── kustomization.yaml
│       └── prod/              # Production environment
│           ├── .env.prod      # Prod environment variables
│           └── kustomization.yaml
│
└── orgfin-frontend/
    ├── base/                  # Base frontend manifests
    └── overlays/
        ├── dev/
        └── prod/
```

## Configuration

### Environment Variables

Environment variables are managed through Kustomize ConfigMaps:

- **Development**: Create `.env` file in `overlays/dev/`
- **Production**: Create `.env.prod` file in `overlays/prod/`

The `HOSTNAME` variable in Ingress configurations is automatically replaced based on environment.

### Example .env file

```bash
DATABASE_URL=postgresql://user:password@host:5432/dbname
REDIS_URL=redis://redis:6379/0
SECRET_KEY=your-secret-key
HOSTNAME=orgfin.yourdomain.com
```

## Deployment

### Manual Deployment with Kustomize

```bash
# Apply specific environment
kubectl apply -k orgfin-backend/overlays/prod
kubectl apply -k orgfin-backend/overlays/dev
kubectl apply -k orgfin-frontend/overlays/prod
kubectl apply -k orgfin-frontend/overlays/dev
```

### Using Apply Scripts

The `apply.sh` scripts in each service directory handle deployment with environment selection:

```bash
cd orgfin-backend
./apply.sh
# Follow prompts to select environment
```

## Monitoring

### View Deployed Resources

```bash
# Deployments
kubectl get deployments

# Services
kubectl get services

# Ingresses
kubectl get ingresses

# Pods
kubectl get pods
```

### Check Pod Logs

```bash
# Backend API
kubectl logs -f deployment/orgfin-backend

# Celery worker
kubectl logs -f deployment/orgfin-celery

# Frontend
kubectl logs -f deployment/orgfin-frontend
```

### Describe Resources

```bash
kubectl describe deployment orgfin-backend
kubectl describe service orgfin-backend
kubectl describe ingress orgfin-ingress
```

## Updating Docker Images

Image versions are managed in deployment YAML files:

1. Update image tag in `base/deployment.yaml`:
   ```yaml
   image: ypeskov/api-orgfin:v2.1.2
   ```

2. Apply changes:
   ```bash
   kubectl apply -k overlays/prod
   ```

3. Verify rollout:
   ```bash
   kubectl rollout status deployment/orgfin-backend
   ```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl get pods

# View pod events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

### ConfigMap not updating

```bash
# Delete existing ConfigMap
kubectl delete configmap orgfin-config

# Reapply configuration
kubectl apply -k overlays/prod

# Restart deployment
kubectl rollout restart deployment/orgfin-backend
```

### Ingress not working

```bash
# Check ingress configuration
kubectl describe ingress orgfin-ingress

# Verify ingress controller is running
kubectl get pods -n ingress-nginx
```

### Database connection issues

1. Check environment variables in ConfigMap:
   ```bash
   kubectl get configmap orgfin-config -o yaml
   ```

2. Verify database connectivity from pod:
   ```bash
   kubectl exec -it <pod-name> -- /bin/bash
   ```

## Scaling

### Manual scaling

```bash
# Scale backend
kubectl scale deployment orgfin-backend --replicas=3

# Scale celery workers
kubectl scale deployment orgfin-celery --replicas=5
```

### Auto-scaling (HPA)

To enable horizontal pod autoscaling, create HPA resource:

```bash
kubectl autoscale deployment orgfin-backend --cpu-percent=70 --min=2 --max=10
```

## Rolling Back

```bash
# View rollout history
kubectl rollout history deployment/orgfin-backend

# Rollback to previous version
kubectl rollout undo deployment/orgfin-backend

# Rollback to specific revision
kubectl rollout undo deployment/orgfin-backend --to-revision=2
```

## License

[Add your license here]
