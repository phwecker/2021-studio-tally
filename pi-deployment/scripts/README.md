# Deployment Scripts

This directory contains all the automated scripts needed to deploy the ATEM Tally system to Raspberry Pi devices.

## ⚠️ IMPORTANT: Static IP Required

**This network does NOT provide DHCP.** You must configure a static IP address AFTER first boot using one of these methods:

1. **Option A (Recommended):** Temporarily connect Pi to a DHCP network, SSH in, configure static IP via raspi-config, then move to studio network
2. **Option B:** Use display/keyboard to configure static IP directly on Pi console using raspi-config

See DEPLOYMENT_GUIDE.md Steps 2-3 for detailed instructions.

## Scripts Overview

### 🔧 create-static-ip-config.sh (Optional - May Not Work)

**⚠️ WARNING**: This script creates a boot partition dhcpcd.conf file, but this method is **unreliable** on newer Raspberry Pi OS versions.

**Purpose**: Creates dhcpcd.conf file for boot partition (legacy method)

**Recommended Alternative**: Configure static IP after first boot using raspi-config instead.

**Usage** (if you want to try anyway):

```bash
./create-static-ip-config.sh
```

**What it does**:

- Warns that this method may not work
- Prompts for device/camera number
- Suggests appropriate static IP (192.168.10.171, .172, .173, etc.)
- Creates dhcpcd.conf file in boot partition (or current directory)
- May or may not be applied by Pi OS on first boot

**When to use**: Not recommended. Use post-boot configuration instead.

---

### 🚀 deploy-to-pi.sh (Run from your Mac)

**Purpose**: Copies all project files from your Mac to a Raspberry Pi

**Usage**:

```bash
./deploy-to-pi.sh
```

**What it does**:

- Tests SSH connection to the Pi
- Creates `/opt/tally` directory on the Pi
- Copies backend and frontend code via rsync
- Copies deployment scripts to `/tmp/tally-scripts/`

**Interactive prompts**:

- Raspberry Pi IP address
- SSH username (default: pi)

---

### 📦 install-tally.sh (Run on the Raspberry Pi)

**Purpose**: Complete installation of dependencies and system configuration

**Usage**:

```bash
/tmp/tally-scripts/install-tally.sh
```

**What it does**:

- Updates system packages
- Installs Node.js, npm, Chromium, X11, and other dependencies
- Installs npm packages for backend and frontend
- Builds the Vue.js frontend
- Creates and enables systemd service for the backend
- Configures kiosk mode for auto-start on boot

**Duration**: ~10-15 minutes (depending on Pi model and network speed)

---

### ⚙️ configure-device.sh (Run on the Raspberry Pi)

**Purpose**: Configure device-specific settings

**Usage**:

```bash
/tmp/tally-scripts/configure-device.sh
```

**What it does**:

- Sets hostname (e.g., tally-cam1)
- Configures static IP address
- Updates tally.config.json with camera/input ID
- Sets ATEM switcher IP address

**Interactive prompts**:

- Camera/Input ID (1-8)
- Static IP address (e.g., 192.168.10.171)
- Hostname (default: tally-cam1, tally-cam2, etc.)
- Gateway IP (default: 192.168.10.1)
- ATEM Switcher IP (default: 192.168.10.240)

---

### 🖥️ setup-kiosk.sh (Automatically called by install-tally.sh)

**Purpose**: Configure X11 and Chromium for kiosk mode

**Usage**:

```bash
./setup-kiosk.sh
```

**What it does**:

- Creates Openbox configuration
- Disables screen blanking
- Hides mouse cursor
- Configures Chromium to launch in fullscreen kiosk mode
- Creates systemd service for auto-starting X server

**Note**: Usually you don't need to run this manually as it's called by install-tally.sh

---

### 🔧 tally.service (Systemd service file)

**Purpose**: Systemd service definition for the tally backend

**Installation** (done automatically by install-tally.sh):

```bash
sudo cp tally.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable tally.service
sudo systemctl start tally.service
```

**Service details**:

- Runs the Node.js backend as user 'pi'
- Auto-restarts on failure
- Starts after network is available
- Logs to systemd journal

---

## Typical Deployment Workflow

### ⚠️ CRITICAL ORDER: Install First, THEN Configure Static IP

**The studio network (192.168.10.x) has NO internet access!**

You MUST complete all system updates and software installations BEFORE configuring the static IP and moving to the studio network.

### For the first device:

**Step 0: Prepare SD Card**

1. **Flash SD card** with Raspberry Pi OS using Raspberry Pi Imager

2. **Configure settings** - Click gear icon ⚙️ in Raspberry Pi Imager:

   - ✅ Enable SSH (password authentication)
   - Set username/password
   - Set hostname (optional)
   - Configure WiFi if needed (optional)

3. **Write to SD card** and wait for completion

4. **Eject SD card** safely and insert into Raspberry Pi

**Step 1: Boot on Internet-Connected Network**

1. **Connect Pi to network with DHCP AND internet** (your main network)
2. **Power on**, wait ~60 seconds
3. **Find Pi's assigned IP** (check router DHCP leases)
4. **SSH into Pi**: `ssh pi@<temporary-ip>`
5. **Change password**: `passwd`

**Step 2: System Updates & Dependencies (REQUIRES INTERNET)**

⚠️ **Do this WHILE on internet-connected network**

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y nodejs npm git chromium xserver-xorg x11-xserver-utils xinit openbox unclutter
```

**Step 3: Deploy Application (REQUIRES INTERNET)**

⚠️ **Still on internet-connected network**

From your Mac:

```bash
cd /Users/phwecker/Dropbox/MICROSOFT/studio/tally/atem-tally
./pi-deployment/scripts/deploy-to-pi.sh
# Enter Pi's temporary IP address
```

**Step 4: Install Application (REQUIRES INTERNET)**

⚠️ **Still on internet-connected network**

On the Pi:

```bash
/tmp/tally-scripts/install-tally.sh
```

This installs npm packages, builds frontend, and configures services.

**Step 5: Configure Static IP (AFTER All Installs)**

⚠️ **Do this ONLY after Steps 2-4 are complete**

```bash
sudo raspi-config
# Navigate to: Advanced Options → Network Config → NetworkManager
# Reboot

# After reboot, SSH back in with temporary IP:
ssh pi@<temporary-ip>

sudo nmtui
# Edit connection → Manual
# Set: Address=192.168.10.171/24, Gateway=192.168.10.1, DNS=192.168.10.1,8.8.8.8
# Save and reboot
```

**Step 6: Move to Studio Network**

1. **Disconnect** from internet network
2. **Connect** to studio network (192.168.10.x subnet)
3. **Wait ~30 seconds**
4. **SSH** to static IP: `ssh pi@192.168.10.171`

**Step 7: Configure Device Settings (No Internet Required)**

```bash
/tmp/tally-scripts/configure-device.sh
```

Enter camera ID, confirm IP, hostname, and ATEM IP.

**Step 8: Final Reboot**

```bash
sudo reboot
```

### For additional devices:

Repeat the ENTIRE workflow, ensuring:

- Different static IP configured after first boot (192.168.10.172, .173, etc.)
- Different camera/input ID during configuration
- Different hostname during configuration

---

## Manual Service Management

### Check service status:

```bash
sudo systemctl status tally.service
sudo systemctl status kiosk.service
```

### View logs:

```bash
sudo journalctl -u tally.service -f
sudo journalctl -u kiosk.service -f
```

### Restart services:

```bash
sudo systemctl restart tally.service
sudo systemctl restart kiosk.service
```

### Stop services:

```bash
sudo systemctl stop tally.service
sudo systemctl stop kiosk.service
```

---

## File Locations After Installation

| Item            | Location                                            |
| --------------- | --------------------------------------------------- |
| Backend code    | `/opt/tally/tally-backend/`                         |
| Frontend code   | `/opt/tally/tally-frontend/`                        |
| Built frontend  | `/opt/tally/tally-frontend/dist/`                   |
| Tally config    | `/opt/tally/tally-backend/config/tally.config.json` |
| Backend service | `/etc/systemd/system/tally.service`                 |
| Kiosk service   | `/etc/systemd/system/kiosk.service`                 |
| Openbox config  | `/home/pi/.config/openbox/autostart`                |
| X init script   | `/home/pi/.xinitrc`                                 |

---

## Troubleshooting

### Scripts won't execute

Make sure scripts are executable:

```bash
chmod +x /tmp/tally-scripts/*.sh
```

### Can't connect to Pi

- Check network connection
- Verify Pi's IP address
- Ensure SSH is enabled (create `ssh` file in boot partition)
- Try default credentials (user: pi, password: raspberry)

### Backend won't start

```bash
# Check logs
sudo journalctl -u tally.service -n 50

# Test manually
cd /opt/tally/tally-backend
node index.js
```

### Kiosk mode not starting

```bash
# Check logs
sudo journalctl -u kiosk.service -n 50
cat ~/.xsession-errors

# Test manually
startx
```

### Wrong camera number displayed

Check and edit the config file:

```bash
nano /opt/tally/tally-backend/config/tally.config.json
```

Then restart the service:

```bash
sudo systemctl restart tally.service
```

---

## Security Recommendations

1. **Change default password immediately**:

   ```bash
   passwd
   ```

2. **Create a new user** (optional but recommended):

   ```bash
   sudo adduser tallyuser
   sudo usermod -aG sudo tallyuser
   ```

   Then update service files to use the new user.

3. **Use SSH keys** instead of passwords:

   ```bash
   # On your Mac
   ssh-copy-id pi@<raspberry-pi-ip>
   ```

4. **Keep system updated**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## See Also

- [DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md) - Detailed deployment guide
- [QUICK_START.md](../QUICK_START.md) - Quick start guide for first deployment
- [prd.md](../prd.md) - Product requirements document
