#!/usr/bin/env bash
# Part 2 - step 9: install Jenkins (LTS) on the SAME EC2 instance (Amazon Linux 2023).
# Jenkins is configured to run as ec2-user so that its pipelines can deploy into
# /home/ec2-user/apps and control the same pm2 processes without sudo.
# Run as ec2-user:  bash 03_install_jenkins.sh
set -euo pipefail

echo ">> Installing Java 21 (required by Jenkins)"
sudo dnf install -y java-21-amazon-corretto fontconfig

echo ">> Adding the Jenkins LTS repository and installing Jenkins"
sudo wget -q -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install -y jenkins

echo ">> Running Jenkins as ec2-user"
sudo mkdir -p /etc/systemd/system/jenkins.service.d
sudo tee /etc/systemd/system/jenkins.service.d/override.conf >/dev/null <<'UNIT'
[Service]
User=ec2-user
Group=ec2-user
UNIT
sudo mkdir -p /var/lib/jenkins /var/cache/jenkins /var/log/jenkins
sudo chown -R ec2-user:ec2-user /var/lib/jenkins /var/cache/jenkins /var/log/jenkins

sudo systemctl daemon-reload
sudo systemctl enable --now jenkins

echo ">> Waiting for Jenkins to create the initial admin password..."
for i in $(seq 1 60); do
  [ -f /var/lib/jenkins/secrets/initialAdminPassword ] && break
  sleep 5
done

echo
echo "Jenkins URL: http://<EC2_PUBLIC_IP>:8080"
echo "Initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword
