# Raspberry Pi Tally Appliance - Product Requirements

## Overview

Create standalone Raspberry Pi-based "appliances" for ATEM tally displays, with one device per camera.

## Requirements

### Deployment

- The code deployed in `tally-backend` and `tally-frontend` should be deployed to a Raspberry Pi and then run unattended
- There should be a re-usable deployment process to create multiple "tally devices" based on the code
- `tally.config.json` contains the parameter `inputID` which defines the difference between those devices
- When the Pi powers up, the web UI (http://localhost:8081) should be displayed in a kiosk-mode browser automatically
- Assume static IP settings for the devices and SSH access only
- The setup instructions should assume factory-fresh Raspberry Pi with nothing set up yet

### Functionality

- Each device monitors a specific ATEM input (camera)
- Display shows tally status with color-coded backgrounds:
  - RED: Camera on program (ON AIR)
  - GREEN: Camera on preview (UP NEXT)
  - YELLOW: Camera in transition
  - MAGENTA: Camera in SuperSource on program
  - GRAY: Camera not selected
- Display shows camera number and IP address
- System runs headless with automatic startup
- No manual intervention required after deployment

### Network Configuration

- Static IP addressing
- SSH access for maintenance
- Connection to ATEM switcher via network

## Implementation Status

✅ **COMPLETE** - All deployment documentation and scripts have been created:

- **QUICK_START.md**: Fast-track deployment guide
- **DEPLOYMENT_GUIDE.md**: Comprehensive step-by-step instructions
- **DEPLOYMENT_CHECKLIST.md**: Verification checklist for each deployment
- **scripts/deploy-to-pi.sh**: Automated file deployment from Mac to Pi
- **scripts/install-tally.sh**: Complete system installation on Pi
- **scripts/configure-device.sh**: Device-specific configuration
- **scripts/setup-kiosk.sh**: Kiosk mode setup
- **scripts/tally.service**: Systemd service for backend

## Getting Started

For your first deployment, see [QUICK_START.md](QUICK_START.md)

For detailed information, see [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
