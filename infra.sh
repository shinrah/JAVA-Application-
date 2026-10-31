
#!/bin/bash

set -Eeuo pipefail

# ==========================================
# DevOps Tools Installation Script
# OS: Ubuntu 24.04 LTS
# Tools: Git, kubectl, eksctl, Terraform
# ==========================================

echo "======================================"
echo " Installing DevOps Tools"
echo " Ubuntu 24.04"
echo "======================================"

# ==========================================
# Step 0: Check and obtain root privileges
# ==========================================

if [ "$(id -u)" -ne 0 ]; then

    echo "Checking Jenkins sudo permissions..."

    if ! sudo -n true 2>/dev/null; then
        echo "ERROR: Passwordless sudo is not configured."
        echo "Configure Jenkins sudo access during server provisioning."
        exit 1
    fi

    echo "Re-executing script with root privileges..."
    exec sudo -n bash "$0" "$@"
fi

echo "Running with root privileges."

# ==========================================
# Step 1: Detect architecture
# ==========================================

ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    amd64)
        BINARY_ARCH="amd64"
        ;;
    arm64)
        BINARY_ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Detected architecture: $ARCH"

# Non-interactive installation
export DEBIAN_FRONTEND=noninteractive

# ==========================================
# Step 2: Update package repository
# ==========================================

echo "Updating package repository..."

apt-get update -y

# ==========================================
# Step 3: Install dependencies and Git
# ==========================================

echo "Installing dependencies and Git..."

apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    gnupg \
    ca-certificates \
    lsb-release

echo "Git installation completed."

# ==========================================
# Step 4: Install kubectl
# ==========================================

echo "Installing kubectl..."

KUBECTL_VERSION=$(curl -fsSL \
    https://dl.k8s.io/release/stable.txt)

echo "Kubectl version: $KUBECTL_VERSION"

curl -fL --retry 3 \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${BINARY_ARCH}/kubectl" \
    -o /tmp/kubectl

install -m 0755 /tmp/kubectl /usr/local/bin/kubectl

echo "kubectl installation completed."

# ==========================================
# Step 5: Install eksctl
# ==========================================

echo "Installing eksctl..."

EKSCTL_URL="https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_${BINARY_ARCH}.tar.gz"

curl -fL --retry 3 \
    "$EKSCTL_URL" \
    -o /tmp/eksctl.tar.gz

tar -xzf /tmp/eksctl.tar.gz -C /tmp

install -m 0755 /tmp/eksctl /usr/local/bin/eksctl

echo "eksctl installation completed."

# ==========================================
# Step 6: Install Terraform
# ==========================================

echo "Installing Terraform..."

install -d -m 0755 /usr/share/keyrings

curl -fsSL \
    https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor --yes \
    -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

chmod 0644 /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" \
    > /etc/apt/sources.list.d/hashicorp.list

apt-get update -y

apt-get install -y terraform

echo "Terraform installation completed."

# ==========================================
# Step 7: Verify all installations
# ==========================================

echo ""
echo "======================================"
echo " Verifying DevOps Tools"
echo "======================================"

echo ""
echo "Git Version:"
git --version

echo ""
echo "Kubectl Version:"
kubectl version --client

echo ""
echo "Eksctl Version:"
eksctl version

echo ""
echo "Terraform Version:"
terraform version

echo "======================================"
echo " AWS Tools"
echo "======================================"

apt-get update && apt-get install -y unzip curl
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q  -o /tmp/awscliv2.zip -d /tmp
/tmp/aws/install --update
aws --version 
# ==========================================
# Step 8: Install Ansible Docker Collection
# ==========================================
echo "installing ansible"
sudo apt update -y
sudo apt install -y ansible-core
sudo chmod 777 /var/run/docker.sock
sudo usermod -aG docker jenkins
#============================================
echo "Installing Ansible Docker collection..."

ansible-galaxy collection install community.docker

echo "Ansible Docker collection installed."

# ==========================================
# Step 9: Verify Ansible
# ==========================================
# ==========================================
# Step 8: Cleanup
# ==========================================

rm -f /tmp/kubectl /tmp/eksctl.tar.gz /tmp/eksctl
ln -sf /usr/local/bin/aws /usr/bin/aws
sudo -u jenkins aws --version 

echo ""
echo "======================================"
echo " Installation Completed Successfully"
echo "======================================"
