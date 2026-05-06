# argocd-declarative
- ArgoCD installation
- Installation of app of apps
- Installation of hello world application
- ArgoCD self management

# Deployment steps:
```bash
helm install argo-cd -n argocd charts/argo-cd/
kubectl get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
helm template charts/root-app/ | kubectl apply -f -
```
Any new argo app placed inside root-app/templates will be automatically picked by argocd

TODE: ECR credentials for argocd are being created manually. Automate this step with the help of external secrets or a cronjob