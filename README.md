# Studio Tally for ATEM Switchers

A comprehensive tally light system for Blackmagic Design ATEM switchers, designed to run on Raspberry Pi devices with web-based displays.

## Overview

This system connects to an ATEM switcher (tally-backend) and displays tally information via a web interface (tally-frontend) in fullscreen kiosk mode. Each Raspberry Pi acts as a dedicated tally monitor for a specific camera input.

**Features:**

- Real-time tally status (Program, Preview, Transition, SuperSource)
- Web-based fullscreen display with color-coded states
- Automatic kiosk mode on boot
- Support for multiple camera inputs
- Works with both X11 and Wayland desktop environments
- Remote deployment and configuration scripts

## System Architecture

- **tally-backend**: Node.js service that connects to ATEM switcher and serves tally status via REST API
- **tally-frontend**: Vue.js web application that displays the tally state in fullscreen
- **Deployment**: Raspberry Pi with Chromium in kiosk mode, auto-starting on boot

## Quick Start

For detailed deployment instructions, see the [pi-deployment](./pi-deployment) folder:

- **[QUICK_START.md](./pi-deployment/QUICK_START.md)** - Fast deployment guide (recommended)
- **[DEPLOYMENT_GUIDE.md](./pi-deployment/DEPLOYMENT_GUIDE.md)** - Comprehensive step-by-step guide
- **[CRITICAL_ORDER_OF_OPERATIONS.md](./pi-deployment/CRITICAL_ORDER_OF_OPERATIONS.md)** - Important deployment sequence

### Deployment Summary

1. **Image SD card** with Raspberry Pi OS (Desktop) using Raspberry Pi Imager
2. **Boot on internet-connected network** (temporary DHCP)
3. **Run automated installation** script to install all dependencies
4. **Configure static IP** for studio network (192.168.10.x)
5. **Move to studio network** and configure device-specific settings
6. **Reboot** - system auto-starts in kiosk mode

## Tally States

- 🔴 **Program (Red)**: Camera is live on program output
- 🟢 **Preview (Green)**: Camera is on preview (ready to go live)
- 🟡 **Transition (Yellow)**: Camera is transitioning between preview and program
- 🟣 **SuperSource (Purple)**: Camera is active in SuperSource on program
- ⚫ **Off (Gray)**: Camera is not selected

## Network Configuration

- **Studio Network**: 192.168.10.x subnet
- **Static IPs**: 192.168.10.171-178 (one per camera)
- **ATEM Switcher**: Default at 192.168.10.240
- **Backend Port**: 8081

## Development

Based on https://github.com/rpitv/atem-tally/tree/add-multiple-tallys

### Local Development

**Backend:**

```bash
cd tally-backend
npm install
node index.js
```

**Frontend:**

```bash
cd tally-frontend
npm install
npm run serve  # Development server
npm run build  # Production build
```

## Repository Structure

```
.
├── README.md
├── tally-backend/          # Node.js backend service
│   ├── index.js            # Main application
│   ├── package.json
│   └── config/
│       └── tally.config.json
├── tally-frontend/         # Vue.js frontend
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── vue.config.js
└── pi-deployment/          # Deployment documentation and scripts
    ├── QUICK_START.md
    ├── DEPLOYMENT_GUIDE.md
    ├── CRITICAL_ORDER_OF_OPERATIONS.md
    ├── DEPLOYMENT_CHECKLIST.md
    └── scripts/
        ├── deploy-to-pi.sh
        ├── install-tally.sh
        ├── configure-device.sh
        └── setup-kiosk.sh
```

## Technical Notes

- Supports Raspberry Pi OS with both X11 (LXDE/Openbox) and Wayland (Labwc) desktop environments
- Uses systemd services for automatic startup
- Chromium runs in kiosk mode with disabled updates and error dialogs
- Frontend build requires Node.js 17+ with OpenSSL legacy provider flag

## License

MIT

## Credits

- Original code: RPI TV (https://github.com/rpitv/atem-tally)
- ATEM Connection library: Blackmagic Design
