#!/bin/bash

# ATEM Tally Kiosk Mode Setup Script
# This script configures a Raspberry Pi to auto-start in kiosk mode
# displaying the tally interface on boot

echo "Setting up ATEM Tally Kiosk Mode..."

# Create openbox autostart directory
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
chromium-browser \
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

# Create systemd service to auto-start X on boot
sudo tee /etc/systemd/system/kiosk.service > /dev/null << 'EOF'
[Unit]
Description=Kiosk Mode X Server
After=tally.service
Wants=tally.service

[Service]
Type=simple
User=pi
Environment=DISPLAY=:0
ExecStart=/usr/bin/startx
Restart=always
RestartSec=5

[Install]
WantedBy=graphical.target
EOF

# Enable kiosk service
sudo systemctl daemon-reload
sudo systemctl enable kiosk.service

echo ""
echo "Kiosk mode setup complete!"
echo ""
echo "The system will now:"
echo "  1. Start the tally backend service on boot"
echo "  2. Automatically launch the web interface in fullscreen"
echo "  3. Hide the mouse cursor"
echo "  4. Disable screen blanking"
echo ""
echo "Reboot the system to activate kiosk mode:"
echo "  sudo reboot"
