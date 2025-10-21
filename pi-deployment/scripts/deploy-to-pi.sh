#!/bin/bash

# ATEM Tally Remote Deployment Script
# This script deploys the tally application to a Raspberry Pi from your local machine

echo "========================================"
echo "ATEM Tally Remote Deployment Script"
echo "========================================"
echo ""

# Check if we're in the correct directory
if [ ! -d "tally-backend" ] || [ ! -d "tally-frontend" ]; then
    echo "Error: This script must be run from the atem-tally project root directory"
    echo "Expected to find: tally-backend/ and tally-frontend/"
    exit 1
fi

# Get target Pi details
read -p "Enter Raspberry Pi IP address: " PI_IP
if [[ -z "$PI_IP" ]]; then
    echo "Error: IP address cannot be empty"
    exit 1
fi

read -p "Enter SSH username [pi]: " PI_USER
PI_USER=${PI_USER:-pi}

echo ""
echo "Deployment target: ${PI_USER}@${PI_IP}"
echo ""

# Test SSH connection
echo "Testing SSH connection..."
if ! ssh -o ConnectTimeout=5 ${PI_USER}@${PI_IP} "echo 'Connection successful'" 2>/dev/null; then
    echo "Error: Cannot connect to ${PI_USER}@${PI_IP}"
    echo "Please check:"
    echo "  - IP address is correct"
    echo "  - SSH is enabled on the Pi"
    echo "  - Network connectivity"
    exit 1
fi

echo "Connection test passed!"
echo ""
read -p "Continue with deployment? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Create directory on Pi
echo ""
echo "Creating application directory on Pi..."
ssh ${PI_USER}@${PI_IP} "sudo mkdir -p /opt/tally && sudo chown -R ${PI_USER}:${PI_USER} /opt/tally"

# Copy backend files
echo ""
echo "Copying backend files..."
rsync -avz --exclude 'node_modules' \
    tally-backend/ ${PI_USER}@${PI_IP}:/opt/tally/tally-backend/

# Copy frontend files
echo ""
echo "Copying frontend files..."
rsync -avz --exclude 'node_modules' --exclude 'dist' \
    tally-frontend/ ${PI_USER}@${PI_IP}:/opt/tally/tally-frontend/

# Copy deployment scripts to permanent location
echo ""
echo "Copying deployment scripts..."
ssh ${PI_USER}@${PI_IP} "mkdir -p /opt/tally/scripts"
scp pi-deployment/scripts/*.service ${PI_USER}@${PI_IP}:/tmp/
scp pi-deployment/scripts/*.sh ${PI_USER}@${PI_IP}:/opt/tally/scripts/
ssh ${PI_USER}@${PI_IP} "chmod +x /opt/tally/scripts/*.sh"

echo ""
echo "============================================"
echo "Files copied successfully!"
echo "============================================"
echo ""
echo "Next steps (run these on the Raspberry Pi):"
echo ""
echo "1. SSH into the Pi:"
echo "   ssh ${PI_USER}@${PI_IP}"
echo ""
echo "2. Run the installation script:"
echo "   /opt/tally/scripts/install-tally.sh"
echo ""
echo "3. Run the configuration script:"
echo "   /opt/tally/scripts/configure-device.sh"
echo ""
echo "4. Reboot the Pi:"
echo "   sudo reboot"
echo ""
echo "Or run all steps automatically (recommended):"
echo "   ssh ${PI_USER}@${PI_IP}"
echo "   /opt/tally/scripts/install-tally.sh && /opt/tally/scripts/configure-device.sh"
echo ""
