# Deployment Checklist

Use this checklist when deploying each tally device to ensure nothing is missed.

## Pre-Deployment Preparation

### Hardware Setup

- [ ] Raspberry Pi 4 (or 3B+)
- [ ] 16GB+ microSD card
- [ ] Raspberry Pi OS Lite flashed to SD card
- [ ] Ethernet cable ready
- [ ] HDMI display ready
- [ ] Power supply ready

### Pre-Boot Configuration

- [ ] Re-inserted SD card into computer after flashing
- [ ] Created empty `ssh` file in boot partition
- [ ] Safely ejected SD card from computer

### Network Configuration Planning

**⚠️ NOTE:** This network does not provide DHCP. Static IP will be configured after first boot.

- [ ] Static IP planned: `___________________` (192.168.10.171-178 range)
- [ ] Gateway IP: `___________________` (typically 192.168.10.1)
- [ ] DNS servers: `___________________` (typically gateway + 8.8.8.8)
- [ ] Camera/Input ID planned: `___________________`
- [ ] Hostname chosen: `___________________`
- [ ] ATEM Switcher IP confirmed: `___________________` (typically 192.168.10.240)

### First Boot & Network Configuration

Choose ONE method:

**Option A: Temporary DHCP Network (Recommended)**

- [ ] Connected Pi to temporary network with DHCP
- [ ] Identified Pi's temporary IP address
- [ ] SSH'd into Pi using temporary IP
- [ ] Configured static IP using raspi-config or manual dhcpcd.conf
- [ ] Rebooted Pi
- [ ] Moved Pi to studio network
- [ ] Verified connectivity at static IP

**Option B: Direct Configuration**

- [ ] Inserted SD card into Raspberry Pi
- [ ] Connected display and keyboard
- [ ] Connected Ethernet cable to studio network
- [ ] Connected power supply
- [ ] Pi powered on
- [ ] Logged in at console (user: pi, password: raspberry)
- [ ] Configured static IP using raspi-config
- [ ] Rebooted Pi
- [ ] Verified connectivity at static IP

## Deployment Steps

### Step 1: Initial Connection

- [ ] Successfully SSH'd into Pi using configured static IP: `ssh pi@___________________`
- [ ] Changed default password using `passwd`
- [ ] Verified network connectivity: `ping 192.168.10.240` (ATEM)
- [ ] Confirmed static IP is active: `ip addr show eth0`

### Step 2: Deploy Files from Mac

- [ ] Opened terminal on Mac
- [ ] Changed to project directory
- [ ] Ran `./pi-deployment/scripts/deploy-to-pi.sh`
- [ ] Entered Pi's IP address
- [ ] Confirmed files copied successfully

### Step 3: Install Software on Pi

- [ ] SSH'd into Pi
- [ ] Ran `/tmp/tally-scripts/install-tally.sh`
- [ ] Installation completed without errors
- [ ] Node.js version confirmed
- [ ] npm packages installed
- [ ] Frontend built successfully

### Step 4: Configure Device

- [ ] Ran `/tmp/tally-scripts/configure-device.sh`
- [ ] Entered Camera/Input ID: `___________________`
- [ ] Entered Static IP: `___________________`
- [ ] Entered/confirmed Hostname: `___________________`
- [ ] Entered/confirmed Gateway: `___________________`
- [ ] Entered/confirmed ATEM IP: `___________________`
- [ ] Confirmed configuration summary
- [ ] Configuration applied successfully

### Step 5: Reboot and Verify

- [ ] Rebooted Pi with `sudo reboot`
- [ ] System booted successfully
- [ ] Backend service started automatically
- [ ] Kiosk mode launched automatically
- [ ] Display shows correct camera number
- [ ] Display shows correct IP address

## Post-Deployment Testing

### Visual Verification

- [ ] Display shows "CAMERA X" with correct number
- [ ] Background is gray (NOT SELECTED) when camera not in use
- [ ] Mouse cursor is hidden
- [ ] Display is fullscreen (no browser chrome visible)

### ATEM Integration Testing

- [ ] Switch camera to PREVIEW on ATEM
  - [ ] Display turns GREEN
  - [ ] Shows "UP NEXT"
- [ ] Switch camera to PROGRAM on ATEM
  - [ ] Display turns RED
  - [ ] Shows "ON AIR"
- [ ] Perform a transition
  - [ ] Display turns YELLOW during transition
  - [ ] Shows "IN TRANSITION"
- [ ] Test SuperSource (if applicable)
  - [ ] Display turns MAGENTA when in SuperSource on program
  - [ ] Shows "SUPERSOURCE"
- [ ] Switch to different camera
  - [ ] Display turns GRAY
  - [ ] Shows "NOT SELECTED"

### Service Status Check

- [ ] SSH into Pi
- [ ] Check tally service: `sudo systemctl status tally.service`
  - [ ] Status is "active (running)"
  - [ ] No error messages
- [ ] Check kiosk service: `sudo systemctl status kiosk.service`
  - [ ] Status is "active (running)"
  - [ ] No error messages

### Network Verification

- [ ] Can ping Pi from Mac: `ping <static-ip>`
- [ ] Pi can ping ATEM: `ping <atem-ip>`
- [ ] Pi has correct static IP: `ip addr show eth0`
- [ ] Pi's hostname is correct: `hostname`

## Documentation

### Record Device Information

| Field           | Value                              |
| --------------- | ---------------------------------- |
| Device Number   | \***\*\*\*\*\***\_\***\*\*\*\*\*** |
| Hostname        | \***\*\*\*\*\***\_\***\*\*\*\*\*** |
| Static IP       | \***\*\*\*\*\***\_\***\*\*\*\*\*** |
| Camera/Input ID | \***\*\*\*\*\***\_\***\*\*\*\*\*** |
| MAC Address     | \***\*\*\*\*\***\_\***\*\*\*\*\*** |
| Serial Number   | \***\*\*\*\*\***\_\***\*\*\*\*\*** |
| Deployment Date | \***\*\*\*\*\***\_\***\*\*\*\*\*** |
| Deployed By     | \***\*\*\*\*\***\_\***\*\*\*\*\*** |

### Label Physical Device

- [ ] Label on Pi: Camera # and IP
- [ ] Label on display: Camera #
- [ ] Label on power supply (if multiple)

## Troubleshooting (If Issues Found)

### Backend Service Not Running

- [ ] Check logs: `sudo journalctl -u tally.service -n 50`
- [ ] Test manually: `cd /opt/tally/tally-backend && node index.js`
- [ ] Check config file: `cat /opt/tally/tally-backend/config/tally.config.json`
- [ ] Verify ATEM IP is reachable: `ping <atem-ip>`

### Kiosk Mode Not Starting

- [ ] Check logs: `sudo journalctl -u kiosk.service -n 50`
- [ ] Check X errors: `cat ~/.xsession-errors`
- [ ] Test manually: `startx`
- [ ] Verify Chromium is installed: `which chromium`

### Wrong Camera Number

- [ ] Edit config: `nano /opt/tally/tally-backend/config/tally.config.json`
- [ ] Restart service: `sudo systemctl restart tally.service`
- [ ] Refresh browser or restart kiosk: `sudo systemctl restart kiosk.service`

### Network Issues

- [ ] Check IP config: `cat /etc/dhcpcd.conf`
- [ ] Check current IP: `ip addr show eth0`
- [ ] Test connectivity: `ping 8.8.8.8`
- [ ] Restart networking: `sudo systemctl restart dhcpcd`

### Display Issues

- [ ] Check HDMI cable connection
- [ ] Check display power
- [ ] Check GPU memory: `vcgencmd get_mem gpu`
- [ ] Check display config: `cat /boot/config.txt`

## Final Sign-Off

- [ ] All tests passed
- [ ] Device labeled correctly
- [ ] Device information documented
- [ ] Device ready for production use

**Deployed by**: \***\*\*\*\*\***\_\***\*\*\*\*\*** **Date**: **\*\*\*\***\_\_\_**\*\*\*\***

**Notes**:

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Multi-Device Deployment Tracker

| Device | Hostname   | Static IP | Input ID | Status | Date | Notes |
| ------ | ---------- | --------- | -------- | ------ | ---- | ----- |
| 1      | tally-cam1 | .101      | 1        | [ ]    |      |       |
| 2      | tally-cam2 | .102      | 2        | [ ]    |      |       |
| 3      | tally-cam3 | .103      | 3        | [ ]    |      |       |
| 4      | tally-cam4 | .104      | 4        | [ ]    |      |       |
| 5      | tally-cam5 | .105      | 5        | [ ]    |      |       |
| 6      | tally-cam6 | .106      | 6        | [ ]    |      |       |
| 7      | tally-cam7 | .107      | 7        | [ ]    |      |       |
| 8      | tally-cam8 | .108      | 8        | [ ]    |      |       |

## Quick Reference Commands

### Check Status

```bash
sudo systemctl status tally.service
sudo systemctl status kiosk.service
```

### View Logs

```bash
sudo journalctl -u tally.service -f
sudo journalctl -u kiosk.service -f
```

### Restart Services

```bash
sudo systemctl restart tally.service
sudo systemctl restart kiosk.service
```

### Manual Testing

```bash
cd /opt/tally/tally-backend
node index.js
```

### Update Configuration

```bash
nano /opt/tally/tally-backend/config/tally.config.json
sudo systemctl restart tally.service
```
