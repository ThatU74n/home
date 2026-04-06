# Home Lab - Showcase project

Homelab infrastructure managed with Terraform (provisioning), Ansible (configuration), and Kubernetes (workloads), self-hosted on Proxmox with a Gitea CI/CD pipeline.

## Stack:
- **Infrastructure**: Terraform, Proxmox, AWS         
- **Configuration**: Ansible                          
- **Kubernetes**: kubeadm, ArgoCD, Longhorn, Tailscale, CloudNativePG                       
- **CI/CD**: Gitea Actions

## Project structure:
```
├── .gitea/                                     # Gitea configuration files (same as .github for GitHub)
│  ├── workflows/**                             # CI/CD workflow definitions
│  ├── ci-filter.yaml                           # Filter configuration for dorny/paths-filter-action
│  └── PULL_REQUEST_TEMPLATE.md                 # Pull request template
│
├── configuration/                              # Ansible projects
│  ├── inventory/                               # Ansible inventory directory
│  │  ├── group_vars/**                         # Inventory group variables
│  │  ├── host_vars/**                          # Inventory host variables
│  │  ├── proxmox.yaml                          # Proxmox dynamic inventory plugin, login via env
│  │  ├── aws_ec2.yml                           # AWS EC2 dynamic inventory plugin, login via env or aws-cli
│  │  └── hosts.yaml                            # Static inventory file, anything not covered by dynamic inventory plugins
│  ├── playbooks/                               # Ansible playbooks
│  │  ├── control_plane.yaml                    # Playbook for Kubernetes control plane nodes
│  │  ├── worker.yaml                           # Playbook for Kubernetes worker nodes
│  │  ├── gitea.yaml                            # Playbook for Gitea installation
│  │  └── local.yaml                            # Playbook for local machine setup to interact with the cluster
│  ├── roles/                                   # Ansible roles
│  │  ├── containerd/                           # Container runtime setup
│  │  ├── docker/                               # Docker installation and configuration
│  │  ├── gitea/                                # Gitea and Gitea runner setup
│  │  ├── helm/                                 # Helm installation
│  │  ├── kubeadm/                              # kubeadm installation and cluster bootstrap
│  │  ├── kubectl/                              # kubectl installation and configuration
│  │  ├── kubelet/                              # kubelet installation
│  │  ├── kubeseal/                             # kubeseal CLI installation
│  │  ├── nginx/                                # Nginx reverse proxy configuration
│  │  ├── tailscale/                            # Tailscale VPN installation
│  │  └── vm/                                   # Preconfigurations for VMs, things i failed to do with cloud-init
│  ├── ansible.cfg                              # Ansible configuration file
│  ├── galaxy.yaml                              # Ansible Galaxy collection requirements
│  └── requirements.yaml                        # Ansible role requirements
│
├── docs/**                                     # Documentation
│
├── infrastructure/                             # Terraform infrastructure code
│  ├── modules/
│  │  ├── aws_compute/                          # AWS EC2 compute module
│  │  ├── proxmox_lxc/                          # Proxmox LXC container module
│  │  └── proxmox_vm/                           # Proxmox VM module
│  ├── backend.tf                               # Terraform backend configuration
│  ├── main.tf                                  # Root Terraform module
│  └── variables.tf                             # Input variable definitions
│
├── k8s/                                        # Kubernetes configuration
│  ├── deployments/                             # Helm chart overrides and app-specific configs
│  │  ├── argocd/                               # ArgoCD HTTPRoute
│  │  ├── chartdb/                              # ChartDB Helm chart
│  │  ├── tailscale/                            # Tailscale operator values and sealed secret
│  │  └── vaultwarden/                          # Vaultwarden Helm chart
│  ├── gitops/                                  # ArgoCD Application manifests
│  │  ├── app.yaml                              # Root app-of-apps
│  │  ├── argocd.yaml                           # ArgoCD self-managed app
│  │  ├── chartdb.yaml                          # ChartDB app
│  │  ├── cloudnativepg.yaml                    # CloudNativePG operator app
│  │  ├── infra.yaml                            # Infrastructure apps umbrella
│  │  ├── longhorn.yaml                         # Longhorn storage app
│  │  ├── tailscale.yaml                        # Tailscale operator app
│  └── manifests/                               # Raw Kubernetes manifests
│     ├── database/                             # CloudNativePG cluster and secrets
│     └── gateway/                              # Gateway API class, config, gateway, and TLS certs
│
└── README.md
```
## Installation
Refer to [installation.md](./docs/installation.md) for a step-by-step guide on how to set up the project, including provisioning the Kubernetes cluster and installing necessary addons.
