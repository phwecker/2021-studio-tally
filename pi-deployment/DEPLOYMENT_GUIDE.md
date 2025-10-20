# Raspberry Pi Tally Appliance Deployment Guide

This guide provides step-by-step instructions for deploying the ATEM Tally system to Raspberry Pi devices, creating standalone "appliances" for each camera.

## Prerequisites

- Raspberry Pi 4 (recommended) or Raspberry Pi 3B+ (one per camera)
- MicroSD card (16GB minimum, 32GB recommended)
- Power supply for Raspberry Pi
- Network connection (Ethernet recommended)
- HDMI display/monitor for each tally device
- SSH access to the Raspberry Pi
- Computer with SD card reader for initial setup

## Hardware Setup & Pre-Boot Configuration

### Step 1: Flash the OS and Enable SSH

1. **Flash Raspberry Pi OS Lite (64-bit)** to your microSD card using Raspberry Pi Imager

2. **After flashing, re-insert the SD card** into your computer to access the boot partition

3. **Enable SSH** - Create an empty file named `ssh` (no extension) in the boot partition:

   ```bash
   # On macOS/Linux:
   touch /Volumes/bootfs/ssh

   # On Windows (in boot drive, e.g., E:):
   # Create empty file named: ssh
   ```

4. **Eject the SD card safely** from your computer

### Step 2: First Boot and Network Access

**⚠️ CRITICAL: Order of Operations**

Since the studio network (192.168.10.x) does **NOT have internet access**, you MUST complete all internet-dependent tasks (updates, installs, downloads) BEFORE configuring the static IP and moving to the studio network.

**Recommended Workflow:**

1. Boot Pi on a network with DHCP AND internet access
2. Find Pi's temporary IP address (check router DHCP leases)
3. SSH into Pi using temporary IP
4. Complete ALL system updates and software installations (Steps 3-4 below)
5. Deploy application code
6. THEN configure static IP (Step 5)
7. Move Pi to studio network

**Option A: Temporary DHCP Network with Internet (Recommended)**

1. Temporarily connect the Pi to a network with DHCP AND internet access (e.g., your main network)
2. Insert microSD card into Raspberry Pi
3. Connect Ethernet cable to internet-connected network
4. Connect HDMI display
5. Power on and wait ~60 seconds for boot
6. Find the Pi's assigned IP address (check router DHCP leases)
7. SSH into Pi: `ssh pi@<temporary-ip>`
8. **IMPORTANT: Complete Steps 3-4 (updates & installs) while on this network**
9. After installation complete, proceed to Step 5 to configure static IP
10. Then move Pi to studio network

**Option B: Direct Configuration via Display (No Internet During Setup)**

⚠️ **This method requires pre-downloading packages or using offline installation methods**

1. Insert microSD card into Raspberry Pi
2. Connect HDMI display and USB keyboard
3. Connect to studio network via Ethernet (no internet)
4. Power on and wait for boot
5. Login at console: username `pi`, password `raspberry`
6. Configure static IP immediately (see Step 5)
7. You'll need to transfer installation packages manually or use deploy script from Mac

### Step 3: System Updates and Dependencies (REQUIRES INTERNET)

⚠️ **DO THIS WHILE CONNECTED TO INTERNET-ENABLED NETWORK (before configuring static IP)**

While SSH'd into the Pi on the temporary network:

1. **Change default password** (security):

   ```bash
   passwd
   # Enter new password when prompted
   ```

2. **Update the system**:

   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **Install required dependencies**:

   ```bash
   sudo apt install -y nodejs npm git chromium-browser xserver-xorg x11-xserver-utils xinit openbox unclutter
   ```

4. **Verify Node.js installation**:

   ```bash
   node --version
   npm --version
   ```

### Step 4: Deploy and Install Application (REQUIRES INTERNET)

⚠️ **DO THIS WHILE STILL CONNECTED TO INTERNET-ENABLED NETWORK**

**Option A: Using deploy script from your Mac**

From your Mac terminal (while Pi is still on internet-connected network):

```bash
cd /Users/phwecker/Dropbox/MICROSOFT/studio/tally/atem-tally
./pi-deployment/scripts/deploy-to-pi.sh
# Enter the Pi's temporary IP address when prompted
```

Then on the Pi, run the installation:

```bash
/tmp/tally-scripts/install-tally.sh
```

This will:

- Install application files to `/opt/tally/`
- Install npm packages (requires internet)
- Build frontend
- Configure systemd services
- Set up kiosk mode

**Option B: Manual deployment**

If you prefer manual steps, see the "Manual Deployment" section at the end of this guide.

### Step 5: Configure Static IP Address (AFTER All Installs Complete)

⚠️ **CRITICAL: Do this AFTER completing Steps 3-4. Once you set static IP and move to studio network, you'll lose internet access.**

After all installations are complete, configure the static IP:

### Step 5: Configure Static IP Address (AFTER All Installs Complete)

⚠️ **CRITICAL: Do this AFTER completing Steps 3-4. Once you set static IP and move to studio network, you'll lose internet access.**

After all installations are complete, configure the static IP:

**Method 1: Using raspi-config (Easiest)**

```bash
sudo raspi-config
```

Navigate to:

- **Advanced Options → Network Config → NetworkManager**
- Reboot when prompted
- After reboot, run:

```bash
sudo nmtui
```

- Select "Edit a connection"
- Select your Ethernet connection
- Change IPv4 Configuration to "Manual"
- Set Address: `192.168.10.171/24` (adjust for each device)
- Set Gateway: `192.168.10.1`
- Set DNS servers: `192.168.10.1, 8.8.8.8`
- Select OK, then Back, then Quit
- Reboot: `sudo reboot`

**Method 2: Manual dhcpcd Configuration (Traditional)**

```bash
sudo nano /etc/dhcpcd.conf
```

Add at the end of the file (adjust IP for each device):

```
interface eth0
static ip_address=192.168.10.171/24
static routers=192.168.10.1
static domain_name_servers=192.168.10.1 8.8.8.8
```

**IMPORTANT - Use unique IP addresses for each tally device:**

- Camera 1: `192.168.10.171`
- Camera 2: `192.168.10.172`
- Camera 3: `192.168.10.173`
- Camera 4: `192.168.10.174`
- etc.

Save (Ctrl+O, Enter) and exit (Ctrl+X), then reboot:

```bash
sudo reboot
```

### Step 6: Move to Studio Network

After the Pi reboots with its static IP:

1. **Disconnect from temporary network**
2. **Connect Pi to studio network** (192.168.10.x subnet, no DHCP, no internet)
3. **Wait ~30 seconds** for network to stabilize
4. **SSH into Pi using static IP**:

   ```bash
   ssh pi@192.168.10.171  # Use your device's specific IP
   ```

### Step 7: Configure Device Settings

Now configure the device-specific settings (camera ID, ATEM IP, etc.):

**Option A: Using configure script**

```bash
/tmp/tally-scripts/configure-device.sh
```

Follow the prompts to set:

- Camera/Input ID (matches ATEM input number)
- Static IP (confirm the one you set)
- Hostname (e.g., tally-cam1)
- Gateway IP (192.168.10.1)
- ATEM Switcher IP (192.168.10.240)

**Option B: Manual configuration**

Edit the configuration file directly:

```bash
sudo nano /opt/tally/tally-backend/config/tally.config.json
```

Update the `inputID` and `switcherIP` values:

```json
{
  "inputID": 1,
  "switcherIP": "192.168.10.240"
}
```

Save and exit.

### Step 8: Final Reboot and Verification

1. **Reboot the Pi**:

   ```bash
   sudo reboot
   ```

2. **Wait ~60 seconds** for the Pi to fully boot

3. **Verify services are running**:

### Step 8: Create Systemd Service

1. **Copy the provided service file to the Pi**. From your local machine:

   ```bash
   scp /Users/phwecker/Dropbox/MICROSOFT/studio/tally/atem-tally/pi-deployment/scripts/tally.service pi@<static-ip>:/tmp/
   ```

2. **On the Pi, install the service**:

   ```bash
   sudo mv /tmp/tally.service /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable tally.service
   ```

3. **Start the service**:

   ```bash
   sudo systemctl start tally.service
   ```

4. **Check service status**:
   ```bash
   sudo systemctl status tally.service
   ```

### Step 9: Configure Kiosk Mode (Auto-start Browser)

1. **Copy the kiosk setup script**. From your local machine:

   ```bash
   scp /Users/phwecker/Dropbox/MICROSOFT/studio/tally/atem-tally/pi-deployment/scripts/setup-kiosk.sh pi@<static-ip>:/tmp/
   ```

2. **On the Pi, run the kiosk setup script**:

   ```bash
   chmod +x /tmp/setup-kiosk.sh
   /tmp/setup-kiosk.sh
   ```

3. **Reboot to activate kiosk mode**:
   ```bash
   sudo reboot
   ```

### Step 10: Verify Installation

After reboot, the system should:

1. Automatically start the backend service
2. Launch Chromium in kiosk mode displaying the tally interface
3. Show the camera number and tally status

**Check that:**

- The display shows "CAMERA X" with the correct number
- The background color changes based on ATEM switcher state
- The tally responds to preview/program changes

## Troubleshooting

### Backend Service Issues

Check logs:

```bash
sudo journalctl -u tally.service -f
```

Restart service:

```bash
sudo systemctl restart tally.service
```

### Kiosk Mode Issues

Check X server logs:

```bash
cat ~/.xsession-errors
```

Test manual start:

```bash
startx
```

### Network Connectivity

Check IP configuration:

```bash
ip addr show eth0
```

Test ATEM switcher connectivity:

```bash
ping 192.168.10.240
```

### Manual Testing

Run backend manually for debugging:

```bash
cd /opt/tally/tally-backend
node index.js
```

## Creating Additional Tally Devices

To deploy additional tally devices, repeat all steps for each Raspberry Pi, ensuring:

1. **Unique hostname** (e.g., tally-cam1, tally-cam2, tally-cam3)
2. **Unique static IP** (e.g., .101, .102, .103)
3. **Correct inputID** in `tally.config.json` matching the ATEM input

## Maintenance

### Updating the Application

1. SSH into the device
2. Stop the service: `sudo systemctl stop tally.service`
3. Update files in `/opt/tally/`
4. Rebuild frontend if needed: `cd /opt/tally/tally-frontend && npm run build`
5. Start the service: `sudo systemctl start tally.service`

### Backup Configuration

Save a copy of `/opt/tally/tally-backend/config/tally.config.json` for each device.

## Quick Reference

| Camera | Hostname   | Static IP      | inputID |
| ------ | ---------- | -------------- | ------- |
| 1      | tally-cam1 | 192.168.10.171 | 1       |
| 2      | tally-cam2 | 192.168.10.172 | 2       |
| 3      | tally-cam3 | 192.168.10.173 | 3       |
| 4      | tally-cam4 | 192.168.10.174 | 4       |

**ATEM Switcher IP**: 192.168.10.240  
**Tally Web Interface**: http://localhost:8081

## Security Notes

- Change the default `pi` user password immediately
- Consider creating a new user and disabling the `pi` user
- Use SSH keys instead of password authentication
- Keep the system updated: `sudo apt update && sudo apt upgrade`
