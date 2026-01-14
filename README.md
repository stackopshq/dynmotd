# dynmotd

[![GitHub](https://img.shields.io/badge/GitHub-stackopshq%2Fdynmotd-blue?logo=github)](https://github.com/stackopshq/dynmotd)

Dynamic MOTD (Message of the Day) for Linux distributions with distribution-specific color coding and cloud provider support.

## Features

- **Distribution-specific colors** based on official logo colors
- **Cloud provider detection**: AWS, Azure, GCP, OpenStack
- **OS-specific modules**: RHEL, Rocky Linux, Proxmox VE, Raspberry Pi, WSL
- **User exclusion**: Hide MOTD for specific users
- **Extensible**: Add custom scripts in `/etc/dynmotd.d/`
- **Fortune integration**: Random quotes (optional)

## Supported Distributions

| Distribution | Color |
|-------------|-------|
| Ubuntu | Orange (#E95420) |
| Debian | Wine Red (#A80030) |
| RHEL/CentOS | Red (#EE0000) |
| Rocky Linux | Green (#10B981) |
| AlmaLinux | Dark Blue (#0F4266) |
| Oracle Linux | Red (#F80000) |
| Fedora | Blue (#3C6EB4) |
| SUSE | Green (#73BA25) |
| Arch Linux | Blue (#1793D1) |
| Manjaro | Green (#35BF5C) |
| Alpine Linux | Blue (#0D597F) |
| Raspbian | Raspberry (#C51A4A) |

## Requirements

Standard tools (available on most Linux distributions):
- `curl`
- `awk`
- `xargs`
- `basename`
- `grep`
- `lsb-release` (for Debian-based)
- `fortune` (optional)

## Installation

### Automatic Installation

```bash
sudo ./install.sh
```

This will:
1. Install `dynmotd` to `/usr/local/bin/`
2. Create symlink `dm` for quick access
3. Set up `/etc/profile.d/dynmotd.sh` for automatic display on login
4. Create `/etc/dynmotd.conf` for user exclusion
5. Create `/etc/dynmotd.d/` for custom scripts
6. Auto-detect OS and cloud provider, installing appropriate modules

### Manual Installation

```bash
# 1. Disable default MOTD (optional)
sudo vi /etc/ssh/sshd_config
# Set: PrintMotd no

# 2. Disable PAM MOTD (if applicable)
sudo vi /etc/pam.d/login
# Comment: # session optional pam_motd.so

# 3. Install dynmotd
sudo cp dynmotd /usr/local/bin/
sudo chmod 755 /usr/local/bin/dynmotd

# 4. Set up auto-display on login
echo "/usr/local/bin/dynmotd" | sudo tee /etc/profile.d/dynmotd.sh
sudo chmod 644 /etc/profile.d/dynmotd.sh

# 5. Create custom scripts directory
sudo mkdir -p /etc/dynmotd.d
```

## Uninstallation

```bash
sudo ./uninstall.sh
```

## Configuration

### Excluding Users

Edit `/etc/dynmotd.conf` to exclude users from seeing the MOTD:

```bash
# /etc/dynmotd.conf
# Add one username per line
root
serviceaccount
jenkins
```

### Custom Scripts

Place custom scripts in `/etc/dynmotd.d/` with `.sh` extension. Scripts are executed in alphabetical order.

**Naming convention:**
- `00_*.sh` - OS-specific info
- `01_*.sh` - Cloud provider info
- `99_*.sh` - Miscellaneous (fortune, etc.)

**Available variables** (exported by dynmotd):
```bash
COLOR_COLUMN    # Bold formatting
COLOR_VALUE     # Distribution color
RESET_COLORS    # Reset to default
DISTRO_COLOR    # Raw distribution color code
```

**Example custom script** (`/etc/dynmotd.d/50_docker.sh`):
```bash
if command -v docker > /dev/null; then
  DOCKER_STATUS=$(systemctl is-active docker 2>/dev/null || echo "not installed")
  echo -e "===== DOCKER ==================================================================
 ${COLOR_COLUMN}${COLOR_VALUE}- Status${RESET_COLORS}.............: ${DOCKER_STATUS}"
fi
```

## Cloud Provider Support

| Provider | Detection Method | Info Displayed |
|----------|-----------------|----------------|
| **AWS** | IMDSv2 token | External IP, Instance ID/Type, Zone |
| **Azure** | Metadata API | External IP, Resource Group, VM ID/Size, Location |
| **GCP** | Metadata header | External IP, Project, Machine Type, Image, VPC, Zone, Scopes |
| **OpenStack** | `/openstack/` endpoint | External IP, Instance ID/Type, Hostname, Project, Zone |

All cloud metadata requests have a **2-second timeout** to prevent delays.

## Project Structure

```
dynmotd/
├── dynmotd              # Main script
├── install.sh           # Installation script
├── uninstall.sh         # Uninstallation script
├── 00_raspberry_pi.sh   # Raspberry Pi module
├── 00_rhel.sh           # RHEL/Oracle Linux module
├── 00_rocky.sh          # Rocky Linux module
├── 00_wsl.sh            # Windows Subsystem for Linux module
├── 00_proxmox.sh        # Proxmox VE host module
├── 01_aws.sh            # AWS EC2 metadata
├── 01_azure.sh          # Azure VM metadata
├── 01_gcp.sh            # GCP Compute Engine metadata
├── 01_openstack.sh      # OpenStack metadata
├── 99_fortune.sh        # Fortune quotes
└── example/             # Example configurations
```

## Sample Output

```
===============================================================================
 - Hostname...........: myserver (192.168.1.100)
 - OS version.........: Rocky Linux 9.2 (Blue Onyx)
 - Kernel release.....: 5.14.0-284.11.1.el9_2.x86_64
 - Users..............: Currently 2 user(s) logged on
===============================================================================
 - CPUs...............: 4 x GenuineIntel/Intel(R) Xeon(R) CPU @ 2.80GHz
 - Load average.......: 0.15 - 0.10 - 0.05 (1-5-15 min)
 - Memory.............: 16Gi - 4.2Gi - 10Gi (total-used-free)
 - Swap...............: 2Gi - 0B - 2Gi (total-used-free)
 - Processes..........: 156 running - 2 background - 0 zombies
 - System uptime......: 45 days 12 hours 30 minutes 15 seconds
===== ROCKY LINUX INFO ========================================================
 - Tuned profile......: virtual-guest
===== GCP INSTANCE METADATA ===================================================
 - External IP........: 34.56.78.90
 - Project ID.........: my-project-123
 - Machine Type.......: e2-medium
 - Image..............: rocky-linux-9-v20230615
 - Preemptible........: FALSE
 - VPC................: default
 - Zone...............: us-central1-a
 - Additional Scopes..: [compute.readonly]
===== FORTUNE =================================================================
The best way to predict the future is to invent it.
                -- Alan Kay
===============================================================================
```

## Credits

This project is a fork of [Neutrollized/dynmotd](https://github.com/Neutrollized/dynmotd).

**Original author**: [Neutrollized](https://github.com/Neutrollized) - Thanks for the original work!

**Maintained by**: [StackOps](https://github.com/stackopshq)

### What's new in this fork

- Distribution-specific color coding based on official logo colors
- OpenStack cloud provider support
- Rocky Linux and Alpine Linux support
- User exclusion configuration (`/etc/dynmotd.conf`)
- Exported color variables for custom scripts
- Timeout on all cloud metadata requests
- Improved error handling and code consistency
