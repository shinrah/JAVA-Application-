#!/bin/bash

echo 'jenkins ALL=(ALL) NOPASSWD: ALL' \
    > /etc/sudoers.d/jenkins

chmod 440 /etc/sudoers.d/jenkins

visudo -cf /etc/sudoers
