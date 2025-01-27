

# Kubernetes Cluster Installation using kubeadm on EC2 Instances

This guide provides a step-by-step process to install a Kubernetes cluster using kubeadm on one EC2 master node and one worker node. The instructions also include setting up containerd as the container runtime.

Blog : [How to create your own CNI ](https://hashnode.com/draft/6791eb67c38544768b02ebdb)


## Prerequisites
1. Two EC2 instances running Ubuntu (one for the master node and one for the worker node) of type `t2.medium`
2. Ensure that both instances have the required network and security group configurations to communicate with each other.

---

## Step 1: Enable IP Forwarding (on both nodes)
Run the following command on both the master and worker nodes:
```bash
sudo sysctl net.ipv4.ip_forward=1
```

---

## Step 2: Install Containerd (on both nodes)
### Download and Install Containerd
```bash
wget https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz
tar xvf containerd-2.0.0-linux-amd64.tar.gz
sudo mv containerd /usr/local/bin/
sudo mv containerd-shim-runc-v2 /usr/local/bin/
sudo mv containerd-stress /usr/local/bin/
sudo mv ctr /usr/local/bin/
```

### Download and Install runc
```bash
wget https://github.com/opencontainers/runc/releases/download/v1.0.3/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

### Install CNI Plugins
```bash
sudo mkdir -p /opt/cni/bin
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
sudo tar -C /opt/cni/bin -xzvf cni-plugins-linux-amd64-v1.1.1.tgz
```

### Create and Configure Containerd Service File
```bash
sudo vi /etc/systemd/system/containerd.service
```
Add the following content:
```ini
[Unit]
Description=Containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStart=/usr/local/bin/containerd
Restart=always

[Install]
WantedBy=multi-user.target
```

### Enable and Start Containerd Service
```bash
sudo systemctl enable containerd
sudo systemctl start containerd
```

---

## Step 3: Install kubeadm, kubelet, and kubectl (on both nodes)
### Add Kubernetes Repository
```bash
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### Install Kubernetes Tools
```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

## Step 4: Additional Utilities (optional, on both nodes)
Install nmap for network debugging:
```bash
sudo apt install nmap -y
```

---

## Step 5: Initialize Kubernetes Cluster (on Master Node)
On the master node, initialize the Kubernetes cluster:
```bash
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```
Save the output of this command as it will include the token required to join the worker node.

### Configure kubectl for the Master Node
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## Step 6: Join Worker Node to the Cluster
Run the command provided by `kubeadm init` output on the worker node to join the cluster. The command looks like this:
```bash
sudo kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
```

---
