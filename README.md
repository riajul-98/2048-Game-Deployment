# 2048-Game-Deployment
This project deploys a containerised 2048 game to an EKS cluster using ArgoCD. Terraform was used to provision infrastructure and GitHub Actions used to automate Docker Image build and deployment to ECR. Prometheus and Grafana used to monitor metrics (installed using Helm).

## Architecture Diagram
![alt text](<./assets/architecture.png>)

## Pre-requisites
- AWS account.
- Git installed and configured locally.
- Terraform installed locally.
- AWS Access Keys
- Route53 Hosted Zone created.
- kubectl utility and AWS CLI installed locally for troubleshooting.

## Project Structure
```

├── .github/
    └── workflows/
        └── build-and-push.yaml
        └── teardown.yaml
        └── terraform-deploy.yaml
        └── trivy-scanner.yaml
├── app-files/
├── apps/
    └── app-hub.yaml
├── argo-cd/
    └── apps-argo.yaml
├── cert-man/
    └── issuer.yaml
├── helm-values/
    └── argocd.yaml
    └── cert-manager.yaml
    └── external-dns.yaml
    └── prometheus-stack.yaml
├── images/
├── scripts/
    └── cleanup.sh
├── terraform/
    └── main.tf
    └── providers.tf
    └── terraform.tfvars
    └── variables.tf
    └── modules
        └── eks/
            └── main.tf
        └── helm/
            └── main.tf
        └── iam
            └── main.tf
        └── vpc
            └── main.tf
├── dockerfile
├── README.md
├── .gitignore
├── .pre-commit-config.yaml

```

## Installation
1. Clone this repository into your repository folder using the below command

    `git clone https://github.com/riajul-98/2048-Game-Deployment.git`

2. Create an Amazon ECR repository.

3. Ensure your GitHub Actions variables and secrets contain the below. You add these by going into your repository settings, Secrets and Variables, Actions.

    ```
    Variables:

    CLUSTER_NAME: project_cluster
    INSTANCE_TYPES: *List of your chosen instance types*
    REGION: eu-west-2
    REGISTRY: *Your ECR URI*
    ROUTE_TABLE_CIDR: *Your route table CIDR*
    SUBNET_CIDR_BLOCKS: *Your subnet CIDR*
    VPC_CIDR_BLOCK: *Your VPC CIDR*

    ```

    ```
    Secrets:

    AWS_ACCESS_KEY_ID: *Your AWS Access Key ID*
    AWS_SECRET_ACCESS_KEY: *Your AWS Secret Access Key*
    HOSTED_ZONE: *Your hosted zone* 

    ```

4. In `apps/app-hub.yaml` change the deployment image to your own image as well as the ingress hosts to your own. In `cert-man/issuer.yaml` change hostedZoneID and dnsZones to your own. In `helm-values/argocd.yaml` change hosts and domains to your own. In `helm-values/cert-manager.yaml` change the account number in the ARN to your own. For `helm-values/external-dns.yaml` do the same as well as changing the domainFilter value. In `helm-values/prometheus-stack.yaml` change the hosts to your own.

5. Push the changes to your own repository using the below commands
    ```

    git add .
    git commit -m "commit message here"
    git push

    ```

6. A pipeline should start which builds the image and pushes it to your ECR repository and then Trivy scans your repository for any vulnerabilities.

7. If the build-and-push pipeline completes successfully, run the terraform-deploy pipeline. This is a manual run. It does take some time so give it maybe 20 minutes max. 

8. You should now be able to access argoCD, Prometheus, Grafana and the 2048 game. Usernames are "admin". Passwords can be located using the below commands:
    ```
    argoCD:

    aws eks --region eu-west-2 update-kubeconfig --name project_cluster
    kubectl -n argo-cd get secrets argo-initial-admin-secret -o yaml

    ```

    ```
    kubectl get secret prometheus-grafana --namespace prometheus -o yaml

    ```

    You should now see the below:
    
    ### ArgoCD

    ![alt text](<assets/argo-cd.png>)

    ### Prometheus

    ![alt text](<assets/prometheus.png>)

    ### Grafana

    ![alt text](<assets/grafana.png>)

    ### Game

    ![alt text](assets/2048-game.gif)

9. Once you are done with the application and wish to tear it down, run the teardown pipeline. This is also a manual triggered pipeline.cd

## Potential Issues
- Site not reachable: If you have deployed the application more than once, you might get "This site can’t be reached" when trying to reach the application. This is due Lets Encrypt having a rate limit of 1 certificate per subdomain per day.
- CI/CD pipeline failing: 
    - You might have incorrectly added secrets and variables. Check the GitHub Actions secrets and variables tab.
    - You might have forgotten to change something in one of the yaml files like hostedZone or the domain.