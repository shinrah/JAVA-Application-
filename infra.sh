
#!/bin/bash

set -e

echo "======================================"
echo " Installing DevOps Tools"
echo " Ubuntu 24.04"
echo "======================================"

# Check root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script using sudo."
    exit 1
fi

# Detect architecture
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

# Update system
echo "Updating package repository..."
apt-get update -y

# Install dependencies and Git
echo "Installing dependencies and Git..."
apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    gnupg \
    ca-certificates \
    lsb-release

# Install kubectl
echo "Installing kubectl..."

KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)

curl -fsSLo /tmp/kubectl \
"https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${BINARY_ARCH}/kubectl"

install -m 0755 /tmp/kubectl /usr/local/bin/kubectl

# Install eksctl
echo "Installing eksctl..."

EKSCTL_VERSION=$(curl -fsSL \
https://api.github.com/repos/eksctl-io/eksctl/releases/latest \
| grep '"tag_name":' \
| head -n 1 \
| cut -d '"' -f 4)

curl -fsSL \
"https://github.com/eksctl-io/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_Linux_${BINARY_ARCH}.tar.gz" \
-o /tmp/eksctl.tar.gz

tar -xzf /tmp/eksctl.tar.gz -C /tmp

install -m 0755 /tmp/eksctl /usr/local/bin/eksctl

# Install Terraform
echo "Installing Terraform..."

install -m 0755 -d /usr/share/keyrings

curl -fsSL https://apt.releases.hashicorp.com/gpg \
| gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" \
> /etc/apt/sources.list.d/hashicorp.list

apt-get update -y

apt-get install -y terraform

# Verify installations
echo ""
echo "======================================"
echo " Installation Completed"
echo "======================================"

echo "Git Version:"
git --version

echo "Kubectl Version:"
kubectl version --client

echo "Eksctl Version:"
eksctl version

echo "Terraform Version:"
terraform version

echo "======================================"
echo " All DevOps tools installed successfully"
echo "======================================"
