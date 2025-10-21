#!/bin/bash

# Fix hostname resolution error
# Run this on a Pi that has "unable to resolve host" errors

echo "Fixing hostname configuration..."

# Get current hostname from /etc/hostname
HOSTNAME=$(cat /etc/hostname)

echo "Current hostname: ${HOSTNAME}"

# Remove any existing 127.0.1.1 entries
sudo sed -i '/^127.0.1.1/d' /etc/hosts

# Add correct entry
echo -e "127.0.1.1\t${HOSTNAME}" | sudo tee -a /etc/hosts > /dev/null

echo ""
echo "Hostname configuration fixed!"
echo "The sudo warning should no longer appear."
echo ""
echo "You can verify by running: cat /etc/hosts"
