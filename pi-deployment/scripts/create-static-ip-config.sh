#!/bin/bash

# Static IP Configuration Generator for Raspberry Pi Boot Partition
# ⚠️ WARNING: This method may not work reliably on newer Raspberry Pi OS versions!
#
# RECOMMENDED APPROACH:
# Configure the network AFTER first boot using one of these methods:
# 1. Temporarily connect Pi to a DHCP network, SSH in, then configure static IP via raspi-config
# 2. Use display/keyboard and raspi-config to configure network directly on Pi console
#
# See DEPLOYMENT_GUIDE.md Steps 2-3 for detailed instructions.
#
# This script is kept for reference but may not work as expected.

echo "========================================"
echo "Raspberry Pi Static IP Configuration"
echo "========================================"
echo ""
echo "⚠️  WARNING: Boot partition configuration may not work reliably!"
echo ""
echo "This script creates a dhcpcd.conf file for the boot partition,"
echo "but this method has proven unreliable on newer Pi OS versions."
echo ""
echo "RECOMMENDED: Configure network AFTER first boot instead."
echo "See DEPLOYMENT_GUIDE.md for detailed instructions."
echo ""
read -p "Continue with boot partition method anyway? (y/N): " CONTINUE
if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Good choice! Follow these steps instead:"
    echo "1. Flash Pi OS and enable SSH (create empty 'ssh' file in boot partition)"
    echo "2. Boot Pi on a temporary DHCP network OR use display/keyboard"
    echo "3. Configure static IP using raspi-config or manual dhcpcd.conf"
    echo ""
    echo "See DEPLOYMENT_GUIDE.md Steps 2-3 for complete instructions."
    exit 0
fi

echo ""
echo "Proceeding with boot partition method..."
echo ""
echo "⚠️  IMPORTANT: This network does NOT provide DHCP."
echo "   Static IP configuration is REQUIRED."
echo ""

# Get the camera/device number
read -p "Enter Camera/Device Number (1-8): " DEVICE_NUM
if ! [[ "$DEVICE_NUM" =~ ^[0-9]+$ ]]; then
    echo "Error: Device number must be a number"
    exit 1
fi

# Calculate static IP based on device number (starting at .171)
STATIC_IP="192.168.10.$((170 + DEVICE_NUM))"

# Get confirmation or allow override
read -p "Suggested static IP: ${STATIC_IP} - Use this? (y/n): " USE_SUGGESTED
if [[ "$USE_SUGGESTED" != "y" && "$USE_SUGGESTED" != "Y" ]]; then
    read -p "Enter custom static IP (e.g., 192.168.10.171): " STATIC_IP
fi

# Get gateway (with default)
read -p "Enter gateway IP address [192.168.10.1]: " GATEWAY
GATEWAY=${GATEWAY:-192.168.10.1}

# Get DNS servers (with default)
read -p "Enter DNS servers [${GATEWAY} 8.8.8.8]: " DNS
DNS=${DNS:-"${GATEWAY} 8.8.8.8"}

echo ""
echo "Configuration Summary:"
echo "----------------------"
echo "Device Number: ${DEVICE_NUM}"
echo "Static IP: ${STATIC_IP}/24"
echo "Gateway: ${GATEWAY}"
echo "DNS Servers: ${DNS}"
echo ""

# Try to detect boot partition
BOOT_PARTITION=""
if [ -d "/Volumes/bootfs" ]; then
    BOOT_PARTITION="/Volumes/bootfs"
elif [ -d "/Volumes/boot" ]; then
    BOOT_PARTITION="/Volumes/boot"
else
    echo "Boot partition not automatically detected."
    read -p "Enter path to boot partition (or leave empty to save to current directory): " BOOT_PARTITION
fi

if [ -z "$BOOT_PARTITION" ]; then
    OUTPUT_FILE="./dhcpcd.conf"
    echo "Will save to current directory: ${OUTPUT_FILE}"
else
    OUTPUT_FILE="${BOOT_PARTITION}/dhcpcd.conf"
    echo "Will save to boot partition: ${OUTPUT_FILE}"
fi

echo ""
read -p "Create configuration file? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Create the dhcpcd.conf file
cat > "$OUTPUT_FILE" << EOF
# Static IP configuration for ATEM Tally Device ${DEVICE_NUM}
# This file will be automatically copied to /etc/dhcpcd.conf on first boot

interface eth0
static ip_address=${STATIC_IP}/24
static routers=${GATEWAY}
static domain_name_servers=${DNS}
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Configuration file created successfully!"
    echo ""
    echo "File location: ${OUTPUT_FILE}"
    echo ""
    echo "Next steps:"
    echo "1. Ensure 'ssh' file also exists in boot partition"
    echo "2. Safely eject SD card"
    echo "3. Insert SD card into Raspberry Pi"
    echo "4. Connect Ethernet and power on"
    echo "5. Wait 60 seconds for boot"
    echo "6. SSH to: ssh pi@${STATIC_IP}"
    echo ""
    echo "Device: Camera ${DEVICE_NUM}"
    echo "IP: ${STATIC_IP}"
    echo "Hostname (suggested): tally-cam${DEVICE_NUM}"
else
    echo ""
    echo "❌ Error creating configuration file!"
    echo "Check permissions and path."
    exit 1
fi
