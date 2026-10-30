#!/bin/bash

set -Eeuo pipefail

# Automatically get root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Re-executing plugin installation with root privileges..."
    exec sudo -n bash "$0" "$@"
fi

echo "===================================="
echo " Installing Jenkins Plugins"
echo "===================================="

JENKINS_HOME="/var/lib/jenkins"
PLUGIN_DIR="$JENKINS_HOME/plugins"
