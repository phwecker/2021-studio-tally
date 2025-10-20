#!/bin/bash

# ATEM Tally Complete Installation Script
# This script automates the installation of the tally system on a fresh Raspberry Pi
# Run this script after copying the project files to /opt/tally

set -e  # Exit on error

echo "============================================"
echo "ATEM Tally System Installation Script"
echo "============================================"
echo ""
echo "This script will:"
echo "  1. Update system packages"
echo "  2. Install dependencies (Node.js, Chromium, X11, etc.)"
echo "  3. Install application packages"
echo "  4. Build the frontend"
echo "  5. Configure systemd service"
echo "  6. Setup kiosk mode"
echo ""
read -p "Continue? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Check if running as pi user
if [ "$USER" != "pi" ]; then
    echo "Warning: This script should be run as the 'pi' user"
    read -p "Continue anyway? (y/n): " CONTINUE
    if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
        exit 0
    fi
fi

echo ""
echo "Step 1: Updating system packages..."
sudo apt update
sudo apt upgrade -y

echo ""
echo "Step 2: Installing dependencies..."
sudo apt install -y \
    nodejs \
    npm \
    git \
    chromium \
    xserver-xorg \
    x11-xserver-utils \
    xinit \
    openbox \
    unclutter

echo ""
echo "Step 3: Verifying Node.js installation..."
node --version
npm --version

echo ""
echo "Step 4: Creating application directory..."
sudo mkdir -p /opt/tally
sudo chown -R pi:pi /opt/tally

echo ""
echo "Step 5: Installing backend dependencies..."
if [ -d "/opt/tally/tally-backend" ]; then
    cd /opt/tally/tally-backend
    npm install
    echo "Backend dependencies installed."
else
    echo "Warning: /opt/tally/tally-backend not found. Please copy project files first."
fi

echo ""
echo "Step 6: Installing frontend dependencies and building..."
if [ -d "/opt/tally/tally-frontend" ]; then
    cd /opt/tally/tally-frontend
    npm install
    npm run build
    echo "Frontend built successfully."
else
    echo "Warning: /opt/tally/tally-frontend not found. Please copy project files first."
fi

echo ""
echo "Step 7: Installing systemd service..."
if [ -f "/tmp/tally.service" ]; then
    sudo mv /tmp/tally.service /etc/systemd/system/
else
    # Create service file if not present
    sudo tee /etc/systemd/system/tally.service > /dev/null << 'EOF'
[Unit]
Description=ATEM Tally Service
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/opt/tally/tally-backend
ExecStart=/usr/bin/node /opt/tally/tally-backend/index.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=tally

[Install]
WantedBy=multi-user.target
EOF
fi

sudo systemctl daemon-reload
sudo systemctl enable tally.service
echo "Tally service installed and enabled."

echo ""
echo "Step 8: Setting up kiosk mode..."

# Create openbox autostart directory (for X11/Openbox systems)
mkdir -p /home/pi/.config/openbox

# Create openbox autostart script
cat > /home/pi/.config/openbox/autostart << 'EOF'
# Disable screen blanking
xset s off
xset s noblank
xset -dpms

# Hide mouse cursor after inactivity
unclutter -idle 0.1 -root &

# Wait for network and backend service to be ready
sleep 10

# Start Chromium in kiosk mode
chromium \
  --kiosk \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --disable-component-update \
  --check-for-update-interval=31536000 \
  --start-fullscreen \
  --app=http://localhost:8081 &
EOF

chmod +x /home/pi/.config/openbox/autostart

# Create xinitrc to start openbox
cat > /home/pi/.xinitrc << 'EOF'
#!/bin/bash
exec openbox-session
EOF

chmod +x /home/pi/.xinitrc

# Create LXDE autostart (for X11/LXDE systems)
mkdir -p /home/pi/.config/lxsession/LXDE-pi

cat > /home/pi/.config/lxsession/LXDE-pi/autostart << 'EOF'
@xset s off
@xset -dpms
@xset s noblank
@unclutter -idle 0.1 -root
@sh -c 'sleep 10 && chromium --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-component-update --check-for-update-interval=31536000 --start-fullscreen --app=http://localhost:8081'
EOF

# Create Labwc autostart (for Wayland/Labwc systems - used in newer Raspberry Pi OS)
mkdir -p /home/pi/.config/labwc

cat > /home/pi/.config/labwc/autostart << 'EOF'
# Wait for tally service to be ready
until curl -s http://localhost:8081/tally > /dev/null 2>&1; do
  sleep 2
done

# Wait an additional moment for frontend to fully load
sleep 3

# Clear any Chromium cache/state to prevent white screen issues
rm -rf /home/pi/.cache/chromium /home/pi/.config/chromium

# Start Chromium in kiosk mode
chromium --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble --disable-component-update --check-for-update-interval=31536000 --start-fullscreen --app=http://localhost:8081 &
EOF

chmod +x /home/pi/.config/labwc/autostart

# Configure autologin to desktop (works on both X11 and Wayland)
echo "Configuring autologin to desktop..."
sudo raspi-config nonint do_boot_behaviour B4 || echo "Note: Auto-login configuration may require manual setup via raspi-config"

echo "Kiosk mode configured and enabled for X11/LXDE and Wayland/Labwc."

echo ""
echo "============================================"
echo "Installation Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Run the configuration script to set device-specific settings:"
echo "     /opt/tally/pi-deployment/scripts/configure-device.sh"
echo ""
echo "  2. Reboot the system to start the tally in kiosk mode:"
echo "     sudo reboot"
echo ""
echo "After reboot, the system will automatically:"
echo "  - Start the tally backend service"
echo "  - Display the tally interface in fullscreen"
echo ""
echo "To check service status after reboot:"
echo "  sudo systemctl status tally.service"
echo "  sudo systemctl status kiosk.service"
echo ""
