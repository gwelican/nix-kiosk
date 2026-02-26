# Raspberry Pi 5 Kiosk Deployment Guide

## Overview

This guide covers deployment of the NixOS-based kiosk system on Raspberry Pi 5 with:
- Firefox ESR in kiosk mode (HomeAssistant dashboard)
- Sway compositor with Wayland display server
- GitOps configuration sync via comin
- Prometheus + Grafana monitoring
- Age-encrypted WiFi credentials

## Prerequisites

### Hardware
- Raspberry Pi 5 (2GB or 4GB model)
- MicroSD card (minimum 32GB, Class 10 recommended)
- WiFi network with credentials
- HomeAssistant instance (for dashboard display)

### Software
- macOS or Linux system with Nix installed (2.25+)
- `nix` command with flakes enabled
- age encryption tool (for WiFi secrets)
- SD card imaging tool (balenaEtcher, Raspberry Pi Imager, or `dd`)

---

## Part 1: SD Card Image Build

### Step 1.1: Build the SD Card Image

From the project root directory:

```bash
# Verify flake evaluation
nix flake show .

# Build the SD card image
nix build .#nixosConfigurations.rpi-kiosk.config.system.build.images.sd-card --accept-flake-config

# Check build output
ls -lh result
```

**Expected output:**
- `result/` symlink pointing to the built image
- Image file: `sd-image-aarch64-linux.img` or similar

### Step 1.2: Image Build Verification

```bash
# Verify sd-card image attribute exists
nix eval .#nixosConfigurations.rpi-kiosk.config.system.build.images --apply 'x: builtins.attrNames x' | grep -q "sd-card" && echo "PASS: sd-card available"

# Verify Firefox configuration
nix eval .#nixosConfigurations.rpi-kiosk.config.programs.firefox.enable | grep -q "true" && echo "PASS: Firefox enabled"

# Verify comin configuration
nix eval .#nixosConfigurations.rpi-kiosk.config.services.comin.enable | grep -q "true" && echo "PASS: comin enabled"

# Verify Prometheus configuration
nix eval .#nixosConfigurations.rpi-kiosk.config.services.prometheus.enable | grep -q "true" && echo "PASS: Prometheus enabled"

# Verify Grafana configuration
nix eval .#nixosConfigurations.rpi-kiosk.config.services.grafana.enable | grep -q "true" && echo "PASS: Grafana enabled"

# Verify Sway configuration
nix eval .#nixosConfigurations.rpi-kiosk.config.programs.sway.enable | grep -q "true" && echo "PASS: Sway enabled"

# Verify SSH configuration
nix eval .#nixosConfigurations.rpi-kiosk.config.services.openssh.enable | grep -q "true" && echo "PASS: SSH enabled"
```

---

## Part 2: SD Card Flashing

### Step 2.1: Identify SD Card Device

```bash
# List block devices (run before inserting SD card)
lsblk

# Insert SD card and identify device
lsblk

# Note the device name (e.g., /dev/sdb, /dev/mmcblk1)
# DO NOT use the partition (e.g., /dev/sdb1) - use the device (/dev/sdb)
```

### Step 2.2: Flash Image to SD Card

**Using `dd` (Linux/macOS):**

```bash
# IMPORTANT: Replace /dev/sdX with your actual SD card device!
# Verify device name carefully to avoid writing to wrong disk

# Flash the image (requires sudo/root)
sudo dd if=result/sd-image-aarch64-linux.img of=/dev/sdX bs=4M status=progress conv=fsync

# Verify flash completed
sync
```

**Using balenaEtcher (cross-platform):**
1. Download and install balenaEtcher from https://www.balena.io/etcher/
2. Select the image file: `result/sd-image-aarch64-linux.img`
3. Select your SD card device
4. Click "Flash!" and wait for completion

**Using Raspberry Pi Imager:**
1. Download Raspberry Pi Imager
2. Choose "Use custom" for OS
3. Select the image file
4. Select SD card device
5. Write the image

### Step 2.3: Verify Flash

```bash
# Check SD card size matches expected (should be ~2GB+)
ls -lh /dev/sdX

# Verify partition table
sudo fdisk -l /dev/sdX
```

---

## Part 3: First Boot Configuration

### Step 3.1: Insert SD Card and Power On

1. Insert the flashed SD card into the Raspberry Pi 5
2. Connect Ethernet cable (optional, for initial setup)
3. Power on the Raspberry Pi 5
4. Wait 2-3 minutes for first boot to complete

### Step 3.2: Configure WiFi Credentials

The system uses age-encrypted WiFi secrets via sops-nix.

**Before first boot:**
1. Edit `secrets/wifi.yaml` with your actual credentials:

```yaml
networking.wifi:
  ssid: "your-wifi-ssid"
  psk: "your-wifi-password"
```

2. Re-encrypt the secrets:

```bash
# Re-encrypt WiFi credentials
sops -e secrets/wifi.yaml > secrets/wifi.age
```

3. Rebuild and flash the image with new credentials, OR

**After first boot (if SD card already flashed without WiFi):**
1. SSH into the Raspberry Pi (see Step 3.3)
2. Replace the encrypted WiFi file
3. Reboot the system

### Step 3.3: SSH Access

**Find the Raspberry Pi IP address:**
- Check your router's DHCP client list
- Use `nmap` on your network: `nmap -sn 192.168.1.0/24`
- Look for host `rpi-kiosk`

**SSH into the system:**

```bash
# SSH with key-based authentication
ssh -i ~/.ssh/id_ed25519 root@<RPi-IP>

# Default root password is NOT set - SSH key authentication only
# If you need password access temporarily, configure it in hosts/rpi-kiosk.nix
```

### Step 3.4: Verify System Boot

```bash
# Check hostname
hostname

# Verify Firefox is running
systemctl status firefox-kiosk

# Verify comin is running
systemctl status comin

# Verify SSH is enabled
systemctl status sshd
```

---

## Part 4: Verification Commands

### System Status Checks

```bash
# System boots correctly
systemctl list-units --type=service | grep -q firefox-kiosk && echo "PASS: Firefox kiosk service present"

# Firefox is running
systemctl status firefox-kiosk | grep -q "active" && echo "PASS: Firefox running"

# comin polling active
systemctl status comin | grep -q "active" && echo "PASS: comin active"

# Prometheus scraping
curl -s http://localhost:9090/api/v1/status | grep -q "ok" && echo "PASS: Prometheus ok"

# Grafana accessible
curl -s http://localhost:3000/api/health | grep -q "ok" && echo "PASS: Grafana ok"

# Sway compositor running
systemctl status sway | grep -q "active" && echo "PASS: Sway running"
```

### Network Checks

```bash
# Check WiFi connection
iwconfig | grep -q "ESSID" && echo "PASS: WiFi connected"

# Check network interfaces
ip addr show | grep -q "inet " && echo "PASS: Network interface configured"

# Test internet connectivity
ping -c 3 8.8.8.8 && echo "PASS: Internet connectivity"
```

### Monitoring Checks

```bash
# Check Prometheus metrics
curl -s http://localhost:9090/api/v1/targets | grep -q "up" && echo "PASS: Prometheus targets up"

# Check Grafana dashboards
curl -s http://localhost:3000/api/dashboards | grep -q "system-metrics" && echo "PASS: Grafana dashboards present"

# Check HA health exporter
systemctl status ha-health-exporter | grep -q "active" && echo "PASS: HA health exporter active"
```

---

## Part 5: Post-Deployment Configuration

### Step 5.1: Configure comin Repository

Edit `hosts/rpi-kiosk.nix` to set your Git repository:

```nix
services.comin = {
  repository = "git@github.com:user/rpi-kiosk-config.git";
  branch = "main";
  pollingInterval = "60s";
};
```

### Step 5.2: Configure SSH Keys (Optional)

If you need to add SSH keys for root access:

```bash
# On your local machine, generate key if not exists
ssh-keygen -t ed25519 -f ~/.ssh/rpi-kiosk

# Copy public key to Raspberry Pi
ssh-copy-id -i ~/.ssh/rpi-kiosk.pub root@<RPi-IP>
```

### Step 5.3: Configure HomeAssistant URL

Edit `hosts/rpi-kiosk.nix` to set the correct HomeAssistant URL:

```nix
programs.firefox.policies.StartPage = "https://homeassistant.local:8123";
# Or use IP address: "http://<HA-IP>:8123"
```

---

## Part 6: Troubleshooting

### Issue: SD Card Image Build Fails

**Symptoms:** `nix build` fails with errors

**Solutions:**
1. Update flake inputs:
   ```bash
   nix flake update
   ```

2. Clean build:
   ```bash
   nix build clean .#nixosConfigurations.rpi-kiosk.config.system.build.images.sd-card
   ```

3. Check Nix version (requires 2.25+ for flakes):
   ```bash
   nix --version
   ```

### Issue: WiFi Not Connecting

**Symptoms:** System boots but no WiFi connection

**Solutions:**
1. Verify WiFi credentials in `secrets/wifi.yaml`:
   ```bash
   cat secrets/wifi.yaml
   ```

2. Re-encrypt with correct credentials:
   ```bash
   sops -e secrets/wifi.yaml > secrets/wifi.age
   ```

3. Rebuild and flash image, OR
4. Replace encrypted file via SSH and reboot

### Issue: Firefox Not Starting

**Symptoms:** System boots to Sway but Firefox not running

**Solutions:**
1. Check Firefox service status:
   ```bash
   systemctl status firefox-kiosk
   ```

2. View service logs:
   ```bash
   journalctl -u firefox-kiosk -n 50
   ```

3. Restart service:
   ```bash
   sudo systemctl restart firefox-kiosk
   ```

4. Verify Firefox policies in config:
   ```bash
   nix eval .#nixosConfigurations.rpi-kiosk.config.programs.firefox.policies --json
   ```

### Issue: comin Not Syncing

**Symptoms:** Configuration not updating from Git

**Solutions:**
1. Check comin service status:
   ```bash
   systemctl status comin
   ```

2. View comin logs:
   ```bash
   journalctl -u comin -n 100
   ```

3. Test Git repository connectivity:
   ```bash
   ssh -T git@github.com
   ```

4. Verify repository URL in config:
   ```bash
   nix eval .#nixosConfigurations.rpi-kiosk.config.services.comin.repository --json
   ```

### Issue: Grafana/Dashboard Not Accessible

**Symptoms:** Cannot access Grafana at port 3000

**Solutions:**
1. Check Grafana service:
   ```bash
   systemctl status grafana
   ```

2. Verify Grafana is listening:
   ```bash
   netstat -tlnp | grep 3000
   ```

3. Test local access:
   ```bash
   curl -s http://localhost:3000/api/health
   ```

4. Check firewall (if enabled):
   ```bash
   sudo nixos-rebuild switch --option network.firewall.allowedTCPPorts '[ 3000 9090 ]'
   ```

### Issue: Display Not Rotated

**Symptoms:** Display shows landscape instead of portrait

**Solutions:**
1. Check display configuration in `hosts/rpi-kiosk.nix`
2. Verify VC4 display overlay is enabled
3. Check current rotation:
   ```bash
   xrandr --query
   ```

### Issue: Touchscreen Not Working

**Symptoms:** Touch input not responding

**Solutions:**
1. Check touchscreen device:
   ```bash
   ls /dev/input/
   ```

2. Verify USB connection:
   ```bash
   dmesg | grep -i touch
   ```

3. Check input drivers:
   ```bash
   sudo modprobe input_core
   ```

---

## Part 7: Maintenance

### Daily Checks

```bash
# System health overview
systemctl list-units --state=running --type=service

# Disk space
df -h /

# Memory usage
free -h

# System logs (recent errors)
journalctl -p err -n 20
```

### Weekly Tasks

```bash
# Check comin sync status
systemctl status comin

# Verify monitoring services
curl -s http://localhost:9090/api/v1/status
curl -s http://localhost:3000/api/health

# Review system logs
journalctl --since "1 week ago" | grep -i error
```

### Monthly Tasks

```bash
# Update system configuration (if needed)
sudo nixos-rebuild switch

# Clean old generations
sudo nix-collect-garbage -d

# Check disk health
sudo smartctl -a /dev/mmcblk0
```

### Emergency Procedures

**System Recovery:**
1. Reboot: `sudo reboot`
2. Check logs: `journalctl -xb`
3. Rollback configuration: `sudo nixos-rebuild boot -i <generation>`

**WiFi Recovery:**
1. Edit `secrets/wifi.yaml`
2. Re-encrypt: `sops -e secrets/wifi.yaml > secrets/wifi.age`
3. Replace encrypted file via SSH
4. Reboot: `sudo reboot`

**Firefox Recovery:**
1. Restart service: `sudo systemctl restart firefox-kiosk`
2. Check logs: `journalctl -u firefox-kiosk`
3. Reset Firefox state (if needed): Remove `/home/root/.mozilla`

---

## Appendix A: Quick Reference

### Build Commands

```bash
# Build SD card image
nix build .#nixosConfigurations.rpi-kiosk.config.system.build.images.sd-card

# Validate flake
nix flake show .

# Check configuration
nix eval .#nixosConfigurations.rpi-kiosk.config --json
```

### Flash Commands

```bash
# dd method
sudo dd if=result/sd-image-aarch64-linux.img of=/dev/sdX bs=4M status=progress conv=fsync

# Verify
sync
```

### SSH Commands

```bash
# Connect to RPi
ssh -i ~/.ssh/id_ed25519 root@<RPi-IP>

# Check services
systemctl status firefox-kiosk comin prometheus grafana
```

### Monitoring URLs

```
# Prometheus: http://<RPi-IP>:9090
# Grafana: http://<RPi-IP>:3000
# Firefox Kiosk: Full screen (configured URL)
```

---

## Appendix B: Configuration Files

### Key Files

- `flake.nix` - Main flake configuration
- `hosts/rpi-kiosk.nix` - Host-specific configuration
- `secrets/wifi.yaml` - WiFi credentials (unencrypted, for editing)
- `secrets/wifi.age` - Encrypted WiFi credentials
- `secrets/age.key` - Age encryption key
- `comin/comin.nix` - comin GitOps module
- `grafana/dashboards/*.json` - Grafana dashboards

### Important Directories

- `/var/lib/comin` - comin working directory
- `/etc/ssh/sshd_config` - SSH configuration
- `/home/root/.mozilla` - Firefox profile
- `/var/lib/grafana` - Grafana data directory

---

## Appendix C: Resources

### Documentation Links

- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Raspberry Pi 5 Support: https://github.com/nvmd/nixos-raspberrypi
- comin GitOps: https://github.com/comin-org/comin
- sops-nix: https://github.com/Mic92/sops-nix
- Firefox ESR: https://www.mozilla.org/en-US/firefox/enterprise/

### Support

For issues or questions:
1. Check troubleshooting section above
2. Review NixOS configuration logs
3. Consult NixOS community forums
4. Check GitHub issues for related packages