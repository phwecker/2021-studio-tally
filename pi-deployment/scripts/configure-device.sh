#!/bin/bash

# ATEM Tally Device Configuration Script
# This interactive script helps configure a new tally device

echo "========================================"
echo "ATEM Tally Device Configuration Script"
echo "========================================"
echo ""

# Get camera/input ID
read -p "Enter the Camera/Input ID (1-8): " INPUT_ID
if ! [[ "$INPUT_ID" =~ ^[0-9]+$ ]]; then
    echo "Error: Input ID must be a number"
    exit 1
fi

# Get static IP address
read -p "Enter the static IP address for this device (e.g., 192.168.10.171): " STATIC_IP
if [[ -z "$STATIC_IP" ]]; then
    echo "Error: Static IP cannot be empty"
    exit 1
fi

# Get hostname
DEFAULT_HOSTNAME="tally-cam${INPUT_ID}"
read -p "Enter hostname for this device [${DEFAULT_HOSTNAME}]: " HOSTNAME
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME}

# Get gateway
read -p "Enter gateway IP address [192.168.10.1]: " GATEWAY
GATEWAY=${GATEWAY:-192.168.10.1}

# Get ATEM switcher IP
read -p "Enter ATEM Switcher IP address [192.168.10.240]: " ATEM_IP
ATEM_IP=${ATEM_IP:-192.168.10.240}

echo ""
echo "Configuration Summary:"
echo "----------------------"
echo "Camera/Input ID: ${INPUT_ID}"
echo "Static IP: ${STATIC_IP}/24"
echo "Hostname: ${HOSTNAME}"
echo "Gateway: ${GATEWAY}"
echo "ATEM Switcher: ${ATEM_IP}"
echo ""
read -p "Is this correct? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Configuration cancelled."
    exit 0
fi

echo ""
echo "Applying configuration..."

# Update hostname
echo "${HOSTNAME}" | sudo tee /etc/hostname > /dev/null

# Update /etc/hosts - remove old 127.0.1.1 entry and add new one
sudo sed -i '/^127.0.1.1/d' /etc/hosts
echo -e "127.0.1.1\t${HOSTNAME}" | sudo tee -a /etc/hosts > /dev/null

# Configure static IP
sudo tee -a /etc/dhcpcd.conf > /dev/null << EOF

# Static IP configuration for ATEM Tally
interface eth0
static ip_address=${STATIC_IP}/24
static routers=${GATEWAY}
static domain_name_servers=${GATEWAY} 8.8.8.8
EOF

# Update tally configuration
TALLY_CONFIG="/opt/tally/tally-backend/config/tally.config.json"
if [ -f "$TALLY_CONFIG" ]; then
    # Create backup
    cp "$TALLY_CONFIG" "${TALLY_CONFIG}.bak"
    
    # Update inputID and switcherIP using sed
    sed -i "s/\"inputID\": [0-9]*/\"inputID\": ${INPUT_ID}/" "$TALLY_CONFIG"
    sed -i "s/\"switcherIP\": \"[^\"]*\"/\"switcherIP\": \"${ATEM_IP}\"/" "$TALLY_CONFIG"
    
    echo "Tally configuration updated."
else
    echo "Warning: Tally configuration file not found at ${TALLY_CONFIG}"
fi

echo ""
echo "Configuration complete!"
echo ""
echo "Please reboot the system to apply changes:"
echo "  sudo reboot"
echo ""
echo "After reboot, this device will be accessible at: ${STATIC_IP}"
