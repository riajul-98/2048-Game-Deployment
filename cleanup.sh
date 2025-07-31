#!/bin/bash

cd terraform

aws eks --region ${ env.REGION } update-kubeconfig --name ${ env.CLUSTER_NAME }

# Delete Helm releases
helm uninstall prometheus -n prometheus
helm uninstall argocd -n argo-cd
helm uninstall external-dns -n external-dns
helm uninstall cert-manager -n cert-manager
helm uninstall nginx-ingress -n nginx-ingress

# Delete Ingress
kubectl delete ingress game-ingress -n apps

# Delete Service
kubectl delete svc game-2048-service -n apps

# Delete Deployment
kubectl delete deployment game-deploy -n apps