# Raspberry Pi Deployment Resources

This directory contains all the resources needed to deploy the ATEM Tally system to Raspberry Pi devices, creating standalone "appliances" for each camera.

## 📚 Documentation

### [QUICK_START.md](QUICK_START.md)

**Start here!** The fastest way to deploy your first tally device. Follow these 5 simple steps to get up and running quickly.

### [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

Comprehensive step-by-step deployment guide covering:

- Initial Raspberry Pi setup
- Static IP configuration
- System dependencies
- Application deployment
- Service configuration
- Kiosk mode setup
- Troubleshooting

### [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)

Printable checklist for deploying and verifying each tally device. Helps ensure consistency across multiple deployments.

### [prd.md](prd.md)

Product requirements document outlining the goals and specifications for the tally appliance system.

## 🛠️ Scripts

All deployment scripts are located in the [`scripts/`](scripts/) directory:

### Run from your Mac:

- **deploy-to-pi.sh**: Copies all project files to a Raspberry Pi

### Run on the Raspberry Pi:

- **install-tally.sh**: Installs all dependencies and configures the system
- **configure-device.sh**: Sets device-specific settings (IP, hostname, camera ID)
- **setup-kiosk.sh**: Configures kiosk mode (automatically called by install-tally.sh)

### System files:

- **tally.service**: Systemd service file for the tally backend

See [scripts/README.md](scripts/README.md) for detailed information about each script.

## 🚀 Quick Deployment

### ⚠️ IMPORTANT: Static IP Required

**This network does not provide DHCP or internet access.** You must complete ALL installations BEFORE configuring static IP. See QUICK_START.md or DEPLOYMENT_GUIDE.md for detailed instructions.

### Initial Setup Workflow

1. **Prepare SD Card**
   - Flash Raspberry Pi OS Lite (64-bit)
   - Enable SSH (create empty `ssh` file in boot partition)
2. **Boot on Internet-Connected Network**
   - Connect Pi to network with DHCP AND internet access
   - Find Pi's temporary IP address
   - SSH into Pi
3. **Complete All Installs (REQUIRES INTERNET)**
   - System updates: `apt update && apt upgrade`
   - Install dependencies: Node.js, npm, Chromium, X server, etc.
   - Deploy application files from Mac
   - Run `install-tally.sh` (installs npm packages, builds frontend)
4. **Configure Static IP (AFTER installs complete)**
   - Use raspi-config or manual dhcpcd configuration
   - IP Range: 192.168.10.171-178 (one per camera)
   - Gateway: 192.168.10.1
   - Reboot
5. **Move to Studio Network**
   - Disconnect from internet network
   - Connect to studio network (192.168.10.x subnet, no DHCP, no internet)
   - ATEM Switcher: 192.168.10.240
6. **Configure Device Settings**
   - SSH into Pi at configured static IP
   - Run `configure-device.sh` for device-specific settings

### What happens automatically:

✅ Backend service starts on boot  
✅ Web interface opens in fullscreen kiosk mode  
✅ Display shows camera number and tally status  
✅ Background color changes with ATEM state

## 📋 Device Planning

Plan your deployment using this template:

| Camera | Hostname   | Static IP      | Input ID | Notes |
| ------ | ---------- | -------------- | -------- | ----- |
| 1      | tally-cam1 | 192.168.10.171 | 1        |       |
| 2      | tally-cam2 | 192.168.10.172 | 2        |       |
| 3      | tally-cam3 | 192.168.10.173 | 3        |       |
| 4      | tally-cam4 | 192.168.10.174 | 4        |       |

**Key settings** (same for all devices):

- ATEM Switcher IP: 192.168.10.240
- Gateway: 192.168.10.1
- Subnet: /24 (255.255.255.0)

## 🎯 System Architecture

```
┌─────────────────────────────────────┐
│     Raspberry Pi Tally Device       │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   Chromium (Kiosk Mode)     │   │
│  │   http://localhost:8081     │   │
│  │   ┌─────────────────────┐   │   │
│  │   │  Tally Display      │   │   │
│  │   │  - Camera Number    │   │   │
│  │   │  - Status Text      │   │   │
│  │   │  - Color-coded BG   │   │   │
│  │   └─────────────────────┘   │   │
│  └─────────────────────────────┘   │
│              ▲                      │
│              │ HTTP                 │
│  ┌───────────┴─────────────────┐   │
│  │   Node.js Backend           │   │
│  │   - Express Server :8081    │   │
│  │   - ATEM Connection         │   │
│  │   - Tally Logic             │   │
│  └─────────────┬───────────────┘   │
└────────────────┼───────────────────┘
                 │ TCP
                 ▼
       ┌─────────────────┐
       │  ATEM Switcher  │
       │  192.168.10.240 │
       └─────────────────┘
```

## 📦 What Gets Deployed

```
/opt/tally/
├── tally-backend/
│   ├── index.js              # Main backend application
│   ├── package.json          # Backend dependencies
│   ├── config/
│   │   └── tally.config.json # Device configuration (inputID)
│   └── node_modules/         # Installed packages
└── tally-frontend/
    ├── dist/                 # Built Vue.js app (served by backend)
    ├── src/                  # Frontend source
    └── package.json          # Frontend dependencies
```

## 🔧 System Services

### tally.service

- Auto-starts Node.js backend on boot
- Restarts automatically on failure
- Location: `/etc/systemd/system/tally.service`

### kiosk.service

- Auto-starts X server and Chromium on boot
- Displays tally interface in fullscreen
- Location: `/etc/systemd/system/kiosk.service`

## 🎨 Tally States

| State       | Color      | Text          | When              |
| ----------- | ---------- | ------------- | ----------------- |
| Program     | 🔴 Red     | ON AIR        | Camera is live    |
| Preview     | 🟢 Green   | UP NEXT       | Camera in preview |
| Transition  | 🟡 Yellow  | IN TRANSITION | During transition |
| SuperSource | 🟣 Magenta | SUPERSOURCE   | In SS on program  |
| Off         | ⚫ Gray    | NOT SELECTED  | Camera not active |

## 🔍 Troubleshooting Quick Reference

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

### Test backend manually:

```bash
cd /opt/tally/tally-backend
node index.js
```

### Edit configuration:

```bash
nano /opt/tally/tally-backend/config/tally.config.json
```

## 📖 Prerequisites

### Hardware:

- Raspberry Pi 4 (recommended) or 3B+
- 16GB+ microSD card
- HDMI display
- Ethernet connection
- Power supply

### Software:

- Raspberry Pi OS Lite (64-bit)
- SSH enabled (create empty `ssh` file in boot partition BEFORE first boot)
- **Static IP configured AFTER first boot** (via raspi-config or temporary DHCP network)

### Network:

- **No DHCP available - static IP configuration is REQUIRED**
- ATEM switcher accessible on network (typically 192.168.10.240)
- Static IP addresses planned for each device (e.g., 192.168.10.171, .172, .173...)
- Gateway IP address (typically 192.168.10.1)
- SSH access capability (may require temporary DHCP network or display/keyboard for initial setup)

## 🛡️ Security Recommendations

1. **Change default password** immediately after first SSH
2. Consider creating a dedicated user instead of using `pi`
3. Use SSH keys instead of password authentication
4. Keep system updated: `sudo apt update && sudo apt upgrade`
5. Use firewall rules to restrict access if needed

## 📝 Support & Maintenance

### Updating the application:

1. SSH into device
2. Stop service: `sudo systemctl stop tally.service`
3. Update files in `/opt/tally/`
4. Rebuild frontend if needed
5. Start service: `sudo systemctl start tally.service`

### Backup important files:

- `/opt/tally/tally-backend/config/tally.config.json`
- Device IP and hostname information

## 📞 Getting Help

If you encounter issues:

1. Check the [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) troubleshooting section
2. Review service logs with `journalctl`
3. Verify network connectivity to ATEM switcher
4. Check that configuration matches your requirements

## 📜 License

MIT License - Same as the parent ATEM Tally project
