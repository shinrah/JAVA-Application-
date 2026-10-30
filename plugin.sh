
#!/bin/bash

set -Eeuo pipefail

echo "===================================="
echo " Installing Jenkins Plugins"
echo "===================================="

# Jenkins home directory
JENKINS_HOME="/var/lib/jenkins"
PLUGIN_DIR="$JENKINS_HOME/plugins"

# Check root permissions
if [ "$(id -u)" -ne 0 ]; then
    echo "Please execute using sudo"
    exit 1
fi

# Check Jenkins Plugin CLI
if ! command -v jenkins-plugin-cli >/dev/null 2>&1; then
    echo "ERROR: jenkins-plugin-cli is not installed."
    exit 1
fi

mkdir -p "$PLUGIN_DIR"

# Install required plugins and dependencies
jenkins-plugin-cli \
    --plugin-download-directory "$PLUGIN_DIR" \
    --plugins \
    git \
    github \
    workflow-aggregator \
    docker-workflow \
    kubernetes-cli \
    sonar \
    aws-credentials \
    pipeline-utility-steps \
    credentials-binding

# Set ownership
chown -R jenkins:jenkins "$PLUGIN_DIR"

echo "===================================="
echo " Jenkins Plugin Installation Done"
echo "===================================="

echo "Installed plugin files:"
ls -lh "$PLUGIN_DIR"
