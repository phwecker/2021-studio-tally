# Quick Start Guide - ATEM Tally Deployment

This guide provides the fastest path to deploying your first tally device.

## Prerequisites Checklist

- [ ] Raspberry Pi 4 with Raspberry Pi OS Lite installed
- [ ] **SSH enabled** (create empty `ssh` file in boot partition before first boot)
- [ ] **Network access** configured (see Step 0 for options)
- [ ] Pi connected to network via Ethernet
- [ ] HDMI display connected to Pi
- [ ] Pi powered on and accessible

## Step 0: Pre-Boot Configuration & Network Setup

**⚠️ CRITICAL ORDER:** The studio network (192.168.10.x) has NO internet access. You MUST do all updates/installs BEFORE configuring static IP.

### Part 1: Prepare SD Card

1. **Flash Raspberry Pi OS Lite** to SD card using Raspberry Pi Imager

2. **Re-insert SD card** into your computer after flashing

3. **Enable SSH** - Create an empty file named `ssh` in the boot partition:

   ```bash
   # On macOS:
   touch /Volumes/bootfs/ssh
   ```

4. **Eject SD card** and insert into Raspberry Pi

### Part 2: First Boot on Internet-Connected Network

**Option A: Temporary DHCP Network with Internet (Recommended)**

1. **Connect Pi to network with DHCP AND internet** (e.g., your main network)
2. **Power on** and wait ~60 seconds
3. **Find Pi's assigned IP** from router DHCP lease page
4. **SSH into Pi**: `ssh pi@<temporary-ip>`
5. **Change default password**: `passwd`
6. **Continue to Step 1 below** - do ALL installs while on this network
7. **THEN** configure static IP (Step 4)
8. **Finally** move to studio network (Step 5)

**Option B: Direct Configuration (No Internet - Advanced)**

1. Boot Pi with display and keyboard
2. Login at console (user: `pi`, password: `raspberry`)
3. You'll need to manually transfer packages or deploy from Mac without internet

## Deployment Steps (Do in Order!)

### 1. System Updates (REQUIRES INTERNET - Do First!)

⚠️ **Do this while Pi is still on internet-connected network**

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y nodejs npm git chromium-browser xserver-xorg x11-xserver-utils xinit openbox unclutter
```

Verify Node.js:

```bash
node --version
npm --version
```

### 2. Deploy Files to Pi (REQUIRES INTERNET)

⚠️ **Still on internet-connected network**

From your Mac terminal:

```bash
cd /Users/phwecker/Dropbox/MICROSOFT/studio/tally/atem-tally
./pi-deployment/scripts/deploy-to-pi.sh
```

Enter Pi's **temporary IP address** when prompted.

### 3. Run Installation Script (REQUIRES INTERNET)

⚠️ **Still on internet-connected network**

SSH to Pi (if not already connected):

```bash
ssh pi@<temporary-ip>
```

Run installation:

```bash
/tmp/tally-scripts/install-tally.sh
```

This will:

- Install application files
- Install Node.js packages (needs internet!)
- Build frontend
- Configure systemd services
- Set up kiosk mode

### 4. Configure Static IP (Do AFTER installs)

⚠️ **Do this ONLY after Steps 1-3 are complete**

While still SSH'd to Pi:

```bash
sudo raspi-config
```

Navigate to: Advanced Options → Network Config → NetworkManager → Reboot

After reboot, SSH back in with temporary IP:

```bash
ssh pi@<temporary-ip>
sudo nmtui
```

- Edit connection → Select Ethernet
- IPv4 Configuration: **Manual**
- Address: `192.168.10.171/24` (change for each device)
- Gateway: `192.168.10.1`
- DNS: `192.168.10.1, 8.8.8.8`
- Save and reboot

**Use unique IPs for each camera:**

- Camera 1: 192.168.10.171
- Camera 2: 192.168.10.172
- Camera 3: 192.168.10.173
- etc.

### 5. Move to Studio Network

1. **Disconnect Pi** from internet network
2. **Connect Pi to studio network** (192.168.10.x subnet)
3. **Wait ~30 seconds** for network to stabilize
4. **SSH into Pi** using new static IP:

   ```bash
   ssh pi@192.168.10.171  # Use your device's IP
   ```

### 6. Configure Device Settings (No Internet Required)

Now on the studio network, configure device-specific settings:

```bash
/tmp/tally-scripts/configure-device.sh
```

You'll be prompted for:

- **Camera/Input ID**: Enter the ATEM input number (1, 2, 3, etc.)
- **Static IP**: Confirm the IP you configured (e.g., 192.168.10.171)
- **Hostname**: Press Enter to accept default (tally-cam1, tally-cam2, etc.)
- **Gateway**: Press Enter to accept default (192.168.10.1)
- **ATEM Switcher IP**: Press Enter to accept default (192.168.10.240) or enter your switcher's IP

### 7. Final Reboot

```bash
sudo reboot
```

## What Happens After Reboot

1. ✅ Tally backend service starts automatically
2. ✅ X server launches in kiosk mode
3. ✅ Chromium opens fullscreen displaying the tally interface
4. ✅ Display shows "CAMERA X" with current tally status
5. ✅ Background color changes based on program/preview state

## Verification

The display should show:

- Large camera number in the center
- Tally status text (ON AIR, UP NEXT, etc.)
- IP address at the bottom
- Background color:
  - **Red** = ON AIR (Program)
  - **Green** = UP NEXT (Preview)
  - **Yellow** = IN TRANSITION
  - **Magenta** = SUPERSOURCE
  - **Gray** = NOT SELECTED

## Deploying Additional Cameras

For each additional camera, repeat all 5 steps with:

- **Different Camera/Input ID** (2, 3, 4, etc.)
- **Different Static IP** (.102, .103, .104, etc.)
- **Different Hostname** (tally-cam2, tally-cam3, etc.)

## Troubleshooting

### Check Backend Service

```bash
sudo systemctl status tally.service
sudo journalctl -u tally.service -f
```

### Check Kiosk Service

```bash
sudo systemctl status kiosk.service
```

### Manual Test Backend

```bash
cd /opt/tally/tally-backend
node index.js
```

### Network Issues

```bash
ping 192.168.10.240  # Test connection to ATEM
ip addr show eth0     # Check IP configuration
```

### View Browser Errors

```bash
cat ~/.xsession-errors
```

## Configuration Reference

| Setting          | Example        | Notes                             |
| ---------------- | -------------- | --------------------------------- |
| Camera/Input ID  | 1, 2, 3, 4     | Must match ATEM input number      |
| Static IP        | 192.168.10.171 | Must be unique for each device    |
| Hostname         | tally-cam1     | Helps identify devices on network |
| ATEM Switcher IP | 192.168.10.240 | Same for all tally devices        |
| Gateway          | 192.168.10.1   | Your network's router IP          |

## Need More Help?

See the full [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed information.

## Summary of Automated Scripts

- **deploy-to-pi.sh**: Copies files from Mac to Pi
- **install-tally.sh**: Installs dependencies and configures services
- **configure-device.sh**: Sets device-specific settings (IP, hostname, camera ID)
- **setup-kiosk.sh**: Configures auto-start browser (called by install-tally.sh)

All scripts are located in `pi-deployment/scripts/`
