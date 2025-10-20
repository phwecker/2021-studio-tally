# ⚠️ CRITICAL: Order of Operations

## The Studio Network Has NO Internet Access!

**This is the most important thing to understand about deployment:**

The studio network (192.168.10.x subnet) does NOT provide:

- DHCP (no automatic IP assignment)
- Internet access (no package downloads, no apt updates)

## Two-Phase Deployment Strategy

### Phase 1: Internet-Connected Network (TEMPORARY)

✅ **Boot Pi on a network WITH internet access**
✅ **Complete ALL installations while on this network**

```
1. Flash SD card with Raspberry Pi OS (Desktop recommended for VNC)
   - Use Raspberry Pi Imager with gear icon ⚙️ to configure:
   - Enable SSH (password authentication)
   - Set username/password
   - Set hostname (optional)
2. Boot Pi on YOUR MAIN NETWORK (with DHCP and internet)
3. Find Pi's temporary IP address
4. SSH into Pi: ssh pi@<temporary-ip>
5. Change default password (if not already set in imager): passwd
6. Enable VNC for remote access (optional but recommended):
   sudo raspi-config → Interface Options → VNC → Yes
   (Connect via VNC client to <temporary-ip>:5900)
7. System updates: sudo apt update && sudo apt upgrade -y
8. Install dependencies: sudo apt install -y nodejs npm git chromium xserver-xorg x11-xserver-utils xinit openbox unclutter
9. Deploy files from Mac: ./pi-deployment/scripts/deploy-to-pi.sh
10. Install application: /tmp/tally-scripts/install-tally.sh
    (This installs npm packages - REQUIRES INTERNET!)
```

### Phase 2: Studio Network (FINAL)

✅ **Configure static IP**
✅ **Move Pi to studio network**
✅ **Configure device settings**

```
12. Configure static IP using raspi-config:
    sudo raspi-config → Advanced Options → Network Config → NetworkManager → Reboot
    sudo nmtui → Edit connection → Manual → 192.168.10.171/24
13. Reboot: sudo reboot
14. PHYSICALLY DISCONNECT from internet network
15. PHYSICALLY CONNECT to studio network
16. Wait ~30 seconds
17. SSH to static IP: ssh pi@192.168.10.171
    (Or connect via VNC to 192.168.10.171:5900 for GUI)
18. Configure device: /tmp/tally-scripts/configure-device.sh
19. Final reboot: sudo reboot
20. Verify via VNC or physical display that kiosk mode is working
```

## What Happens If You Do It Wrong

❌ **If you configure static IP FIRST:**

- Pi moves to studio network (no internet)
- `apt update` fails
- `apt install` fails
- `npm install` fails
- Frontend build fails
- YOU'RE STUCK - have to start over or manually transfer packages

✅ **If you install FIRST (correct order):**

- All packages download successfully
- Everything installs properly
- Static IP configuration is last step
- Pi works perfectly on studio network

## Quick Reference Card

### Phase 1: On Internet Network

- [ ] Flash SD card (use Raspberry Pi OS with Desktop for VNC support)
- [ ] Use Raspberry Pi Imager's gear icon ⚙️ to enable SSH and configure settings
- [ ] Boot on internet-connected network with DHCP
- [ ] Find temporary IP
- [ ] SSH in
- [ ] Change password (if not set in imager)
- [ ] Enable VNC (optional, for remote GUI access)
- [ ] `apt update && upgrade`
- [ ] `apt install` dependencies (including VNC server if needed)
- [ ] Deploy files from Mac
- [ ] Run `install-tally.sh` (npm install happens here!)

### Phase 2: Move to Studio Network

- [ ] Configure static IP with raspi-config/nmtui
- [ ] Reboot
- [ ] Disconnect from internet network
- [ ] Connect to studio network
- [ ] SSH to static IP (or connect via VNC)
- [ ] Run `configure-device.sh`
- [ ] Final reboot
- [ ] Verify kiosk mode via VNC or physical display

## IP Address Assignments

Studio network static IPs:

- Camera 1: 192.168.10.171
- Camera 2: 192.168.10.172
- Camera 3: 192.168.10.173
- Camera 4: 192.168.10.174
- Camera 5: 192.168.10.175
- Camera 6: 192.168.10.176
- Camera 7: 192.168.10.177
- Camera 8: 192.168.10.178

Network settings:

- Gateway: 192.168.10.1
- DNS: 192.168.10.1, 8.8.8.8
- Subnet: /24 (255.255.255.0)
- ATEM Switcher: 192.168.10.240

## Remember

🔴 **Internet-dependent tasks MUST happen BEFORE configuring static IP**
🟢 **Device-specific configuration happens AFTER moving to studio network**

The key insight: Your studio network is isolated (good for security/performance) but this requires a two-phase deployment strategy.

---

_This order of operations is now reflected in all documentation:_

- DEPLOYMENT_GUIDE.md
- QUICK_START.md
- README.md
- INDEX.md
- scripts/README.md
- DEPLOYMENT_CHECKLIST.md
