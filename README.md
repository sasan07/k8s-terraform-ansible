# Kubernetes Cluster on AWS: Terraform + Ansible

Automated setup of a 4-node Kubernetes cluster on AWS.

- **Terraform** creates the VPC, subnet, internet gateway, route table, an all-traffic security group and 4 EC2 instances.
- **Ansible** (run from the control machine where Terraform is installed) installs Kubernetes on all nodes.
- **kubeadm** initializes the cluster (1 master, 3 workers) with Calico as the pod network.
- **kubectl** deploys nginx and apache2 Deployments exposed through NodePort services.

## Repository layout

| Path | Purpose |
|---|---|
| `terraform/main.tf` | Infrastructure: VPC, subnet, IGW, route table, security group, 4 instances |
| `ansible/hosts` | Ansible inventory (master and worker groups) |
| `ansible/k8s-install.yml` | Playbook that installs Kubernetes on the nodes |
| `ansible/ansible.sh` | Helper script used with the Ansible setup |
| `kubernetes/nginx.yaml` | nginx Deployment and NodePort service |
| `kubernetes/apache.yaml` | apache2 Deployment and NodePort service |

## Steps

1. **Control machine:** create an Ubuntu instance manually and install Terraform and Ansible.
2. **Provision:** `cd terraform && terraform init && terraform apply -auto-approve`
3. **Connect Ansible:** put the node IPs in the inventory and check with `ansible all -m ping`.
4. **Install Kubernetes:** `ansible-playbook ansible/k8s-install.yml`
5. **Initialize the cluster:** run `kubeadm init` on the master, apply Calico, and join the workers with the printed join command.
6. **Deploy apps:** `kubectl apply -f kubernetes/nginx.yaml` and `kubectl apply -f kubernetes/apache.yaml`
7. **Verify:** `kubectl get nodes`, `kubectl get pods -o wide`, `kubectl get svc`, then open the NodePort URLs on any node IP.

## Screenshots

Add the screenshots of each step here.
