#!/bin/bash

# ATEM Tally Kiosk Mode Setup Script
# This script configures a Raspberry Pi to auto-start in kiosk mode
# displaying the tally interface on boot

echo "Setting up ATEM Tally Kiosk Mode..."

# Create openbox autostart directory
mkdir -p /home/pi/.config/openbox

# Create openbox autostart script (for Openbox-only systems)
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

# Also create LXDE autostart (for Raspberry Pi OS with Desktop)
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

# Configure autologin to desktop (works on Raspberry Pi OS with Desktop)
echo "Configuring autologin to desktop..."
sudo raspi-config nonint do_boot_behaviour B4 || echo "Note: Auto-login configuration may require manual setup via raspi-config"

echo ""
echo "Kiosk mode setup complete!"
echo ""
echo "The system will now:"
echo "  1. Start the tally backend service on boot"
echo "  2. Automatically launch the web interface in fullscreen"
echo "  3. Hide the mouse cursor (X11 systems)"
echo "  4. Disable screen blanking (X11 systems)"
echo ""
echo "Supports: X11/Openbox, X11/LXDE, and Wayland/Labwc desktop environments"
echo ""
echo "Reboot the system to activate kiosk mode:"
echo "  sudo reboot"
