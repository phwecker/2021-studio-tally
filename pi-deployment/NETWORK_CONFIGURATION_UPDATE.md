# Network Configuration Update - January 2025

## What Changed

The deployment documentation has been updated to reflect the **correct and reliable method** for configuring static IP addresses on Raspberry Pi devices.

### Previous (Unreliable) Method ❌

- Created `dhcpcd.conf` file in boot partition BEFORE first boot
- Expected Pi OS to automatically apply configuration on first boot
- **This method does NOT work reliably on newer Raspberry Pi OS versions**

### Current (Reliable) Method ✅

Configure static IP **AFTER first boot** using one of two methods:

#### Option A: Temporary DHCP Network (Recommended)

1. Flash Pi OS Lite and enable SSH (create empty `ssh` file in boot partition)
2. Boot Pi on a network with DHCP (temporarily)
3. Find Pi's assigned IP from router DHCP leases
4. SSH into Pi using temporary IP
5. Configure static IP using `raspi-config`:
   ```bash
   sudo raspi-config
   # Advanced Options → Network Config → NetworkManager → Reboot
   sudo nmtui
   # Edit connection → Manual IPv4 → Set: 192.168.10.171/24, Gateway: 192.168.10.1, DNS: 192.168.10.1,8.8.8.8
   ```
6. Reboot: `sudo reboot`
7. Move Pi to studio network (no DHCP)
8. SSH into Pi at static IP: `ssh pi@192.168.10.171`

#### Option B: Direct Configuration

1. Flash Pi OS Lite and enable SSH
2. Boot Pi with display and keyboard connected
3. Connect to studio network via Ethernet
4. Login at console (user: `pi`, password: `raspberry`)
5. Configure static IP using `raspi-config` (same process as above)
6. Reboot
7. SSH into Pi at static IP: `ssh pi@192.168.10.171`

## Updated Files

All documentation has been updated:

- ✅ `DEPLOYMENT_GUIDE.md` - Steps 1-4 completely rewritten
- ✅ `QUICK_START.md` - Step 0 updated with new method
- ✅ `README.md` - Prerequisites and workflow updated
- ✅ `DEPLOYMENT_CHECKLIST.md` - Pre-boot and network sections rewritten
- ✅ `INDEX.md` - Workflow and checklist updated
- ✅ `scripts/README.md` - Workflow section rewritten
- ✅ `scripts/create-static-ip-config.sh` - Added warning about unreliability

## Static IP Address Assignments

Use these IP addresses for your tally devices:

| Camera | IP Address     |
| ------ | -------------- |
| 1      | 192.168.10.171 |
| 2      | 192.168.10.172 |
| 3      | 192.168.10.173 |
| 4      | 192.168.10.174 |
| 5      | 192.168.10.175 |
| 6      | 192.168.10.176 |
| 7      | 192.168.10.177 |
| 8      | 192.168.10.178 |

**Network Configuration:**

- Gateway: `192.168.10.1`
- DNS: `192.168.10.1, 8.8.8.8`
- Subnet: `/24` (255.255.255.0)
- ATEM Switcher: `192.168.10.240`

## Quick Reference

### Using raspi-config (Recommended Method)

After first SSH connection:

```bash
# Switch to NetworkManager
sudo raspi-config
# Navigate: Advanced Options → Network Config → NetworkManager
# Select OK, then reboot

# After reboot, configure interface
sudo nmtui
# Select: Edit a connection
# Select your Ethernet connection
# Change IPv4 Configuration to: Manual
# Set Address: 192.168.10.171/24 (adjust for each device)
# Set Gateway: 192.168.10.1
# Set DNS: 192.168.10.1, 8.8.8.8
# Select OK, Back, Quit

# Reboot
sudo reboot
```

### Manual dhcpcd Method (Alternative)

After first SSH connection:

```bash
sudo nano /etc/dhcpcd.conf
```

Add at the end:

```
interface eth0
static ip_address=192.168.10.171/24
static routers=192.168.10.1
static domain_name_servers=192.168.10.1 8.8.8.8
```

Save (Ctrl+O, Enter) and exit (Ctrl+X), then:

```bash
sudo reboot
```

## Why This Change?

The boot partition `dhcpcd.conf` method was documented in older guides but has become unreliable:

1. Newer Raspberry Pi OS versions may use NetworkManager instead of dhcpcd
2. Boot partition files are not always processed on first boot
3. The method worked inconsistently depending on Pi OS version and configuration

The post-boot configuration method using `raspi-config` or direct file editing is:

- More reliable
- Officially supported
- Works consistently across all Pi OS versions
- Better documented in official Pi documentation

## What to Do Now

For devices already deployed:

- ✅ No action needed - they're already working with static IPs

For new deployments:

- ✅ Follow the updated guides (QUICK_START.md or DEPLOYMENT_GUIDE.md)
- ✅ Use Option A (temporary DHCP) or Option B (display/keyboard) for initial network configuration
- ✅ Configure static IP after first boot using raspi-config

---

_Last Updated: January 2025_
