#!/bin/bash

# Enable IP Forwarding
sudo sysctl net.ipv4.ip_forward=1

# Install Containerd
wget https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz
tar xvf containerd-2.0.0-linux-amd64.tar.gz
sudo mv containerd /usr/local/bin/
sudo mv containerd-shim-runc-v2 /usr/local/bin/
sudo mv containerd-stress /usr/local/bin/
sudo mv ctr /usr/local/bin/

wget https://github.com/opencontainers/runc/releases/download/v1.0.3/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

sudo mkdir -p /opt/cni/bin
wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
sudo tar -C /opt/cni/bin -xzvf cni-plugins-linux-amd64-v1.1.1.tgz

sudo bash -c 'cat > /etc/systemd/system/containerd.service' <<EOF
[Unit]
Description=Containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStart=/usr/local/bin/containerd
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable containerd
sudo systemctl start containerd

# Install Kubernetes Tools
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Install Additional Utilities
sudo apt install nmap -y

echo "Setup complete. Follow the guide to initialize or join the cluster."

