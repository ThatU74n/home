# Installation Guide

This guide walks through provisioning the Kubernetes cluster and getting workloads running via ArgoCD.

---

## 1. Prerequisites

Export the required credentials as environment variables before running any tooling.

**Proxmox**
```bash
export PROXMOX_USER="<user>@pam"
export PROXMOX_TOKEN_ID="<token-id>"
export PROXMOX_TOKEN_SECRET="<token-secret>"
```

**AWS** (S3 backend + EC2 dynamic inventory)
```bash
export AWS_ACCESS_KEY_ID="<access-key>"
export AWS_SECRET_ACCESS_KEY="<secret-key>"
export AWS_DEFAULT_REGION="<region>"
```

---

## 2. Provision infrastructure

Edit `infrastructure/terraform.tfvars` to set the desired number of control plane and worker nodes, then apply:

```bash
cd infrastructure
terraform init
terraform apply
```

This provisions VMs on Proxmox and any AWS EC2 nodes defined in the config.

---

## 3. Configure nodes with Ansible

Run the playbooks in order. The dynamic inventory plugins will pick up nodes using the exported credentials.

```bash
cd configuration
ansible-playbook playbooks/control_plane.yaml
ansible-playbook playbooks/worker.yaml
ansible-playbook playbooks/local.yaml
```

> **Note:** The cluster join sequence is not yet automated. Nodes are provisioned and configured up to just before `kubeadm join`. Manual joining is required at this stage.

---

## 4. Bootstrap the cluster

### Install Gateway API CRDs
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/1.4.0/download/standard-install.yaml
```
> **Note:** Cilium may not work properly with gateway API v1.5.0+

### Install Cilium
```bash
cilium install
```

---

## 5. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Once ArgoCD is running, apply the root app-of-apps to hand off the rest of the deployment:

```bash
kubectl apply -f k8s/gitops/app.yaml
```

ArgoCD will reconcile all remaining applications defined under `k8s/gitops/`.
