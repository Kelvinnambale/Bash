# NamsTech Digital Solutions
## Linux System Information Report Generator

A comprehensive Linux system information report generator that creates detailed HTML and PDF reports containing system hardware, performance, network, security, and configuration information.

## 🚀 Features

- **10 Comprehensive Report Sections**:
  1. Hardware Information (CPU, Memory, Storage, Devices)
  2. Performance & Processes (System Load, Running Processes)
  3. Network Information (Interfaces, Routing, Connections)
  4. System Configuration (OS Info, Users, Mount Points)
  5. Service Management (Systemd Services, Cron Jobs)
  6. Logging & Monitoring (System Logs, Boot Messages)
  7. Package Management (Installed Packages, Updates)
  8. Security Information (Firewall, Permissions, Ports)
  9. Kernel Information (Modules, Configuration)
  10. Environment Information (Variables, Locale, Timezone)

- **Multi-Format Output**: Generates both HTML and PDF reports
- **Automatic PDF Tool Installation**: Installs wkhtmltopdf automatically
- **Administrator Information**: Captures admin details for report header
- **Flexible Section Selection**: Choose specific sections or generate complete reports
- **Multi-Distribution Support**: Works on Ubuntu, Debian, CentOS, RHEL, Fedora, Arch, Alpine, openSUSE
- **Professional Formatting**: Clean, organized output with proper styling

## 📋 Prerequisites

### System Requirements
- Linux operating system
- Bash shell
- Root/sudo privileges
- Internet connection (for automatic PDF tool installation)

### Supported Distributions
- **Debian/Ubuntu**: `apt` package manager
- **RHEL/CentOS/Fedora**: `yum`/`dnf` package manager
- **Arch Linux**: `pacman` package manager
- **Alpine Linux**: `apk` package manager
- **openSUSE**: `zypper` package manager

## 🔧 Installation

### Method 1: Clone from GitHub (Recommended)
```bash
# Clone the repository
git clone https://github.com/Kelvinnambale/Bash.git

# Navigate to the project directory
cd Bash

# Make the script executable
chmod +x system_report1.sh

# Run the script
sudo ./system_report1.sh
```

### Method 2: Direct Download
```bash
# Download the script directly
wget https://github.com/Kelvinnambale/Bash/main/system_report1.sh

# Make it executable
chmod +x system_report1.sh

# Run the script
sudo ./system_report1.sh
```

### Method 3: Manual Setup
1. Save the script content to a file named `system_report.sh`
2. Make it executable:
   ```bash
   chmod +x system_report1.sh
   ```
3. Run with sudo privileges:
   ```bash
   sudo ./system_report.sh
   ```

### Method 3: System-wide Installation
```bash
# First, clone the repository
git clone https://github.com/Kelvinnambale/Bash.git
cd Bash

# Copy to system binary directory
sudo cp system_report.sh /usr/local/bin/system-report

# Make it executable
sudo chmod +x /usr/local/bin/system-report

# Run from anywhere
sudo system-report
```

## 📦 Repository Information

- **GitHub Repository**: [https://github.com/Kelvinnambale/Bash](https://github.com/Kelvinnambale/Bash)
- **Direct Script URL**: `https://github.com/Kelvinnambale/Bash/main/system_report1.sh`
- **Clone Command**: `git clone https://github.com/Kelvinnambale/Bash.git`

## 📖 Usage

### Basic Usage
```bash
# If cloned from GitHub
cd Bash
sudo ./system_report.sh

# If installed system-wide
sudo system-report

# If downloaded directly
sudo ./system_report.sh
```

### Step-by-Step Process

1. **Clone and Run the Script**:
   ```bash
   git clone https://github.com/Kelvinnambale/Bash.git
   cd Bash
   chmod +x system_report.sh
   sudo ./system_report.sh
   ```

2. **Administrator Details**: The script will prompt for:
   - Administrator Name
   - Email Address
   - Department
   - Organization

3. **Section Selection**: Choose from the menu:
   - Enter numbers 1-10 for specific sections
   - Enter `*` to select all sections
   - Enter `0` to finish selection

4. **Save Location**: Choose where to save reports:
   - Current directory
   - `/tmp` directory
   - `/var/log` directory
   - Custom directory

5. **Report Generation**: The script will:
   - Collect system information
   - Generate HTML report
   - Create PDF report (if tools are available)

### Example Interactive Session
```
╔══════════════════════════════════════════════════════════════════════╗
║                              NamsTech                                 ║
║              Linux System Information Report Generator               ║
╚══════════════════════════════════════════════════════════════════════╝

✓ Running with administrative privileges
✓ wkhtmltopdf found
✓ Will use wkhtmltopdf for PDF generation

Please enter Linux Administrator details:

Administrator Name: John Smith
Email Address: john.smith@company.com
Department: IT Operations
Organization: Acme Corporation

Select the information sections to include in your report:

  1. Hardware Information (CPU, Memory, Storage, Devices)
  2. Performance & Processes (System Load, Running Processes)
  3. Network Information (Interfaces, Routing, Connections)
  ...

Enter your choice (1-10, *, or 0 to finish): *
✓ All sections selected

Choose where to save the report:
  1. Current directory (/home/admin)
  2. /tmp directory
  3. /var/log directory
  4. Custom directory

Enter your choice (1-4): 1
✓ Reports will be saved to: /home/admin
```

## 🛠️ Automatic Dependency Installation

The script automatically detects your Linux distribution and installs required PDF generation tools:

### Supported Package Managers
- **apt** (Debian/Ubuntu): `apt install wkhtmltopdf`
- **yum** (RHEL/CentOS): `yum install wkhtmltopdf`
- **dnf** (Fedora): `dnf install wkhtmltopdf`
- **pacman** (Arch): `pacman -S wkhtmltopdf`
- **apk** (Alpine): `apk add wkhtmltopdf`
- **zypper** (openSUSE): `zypper install wkhtmltopdf`

### Manual Installation (if automatic fails)
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install wkhtmltopdf

# RHEL/CentOS
sudo yum install wkhtmltopdf

# Fedora
sudo dnf install wkhtmltopdf

# Arch Linux
sudo pacman -S wkhtmltopdf

# Alpine Linux
sudo apk add wkhtmltopdf

# openSUSE
sudo zypper install wkhtmltopdf
```

## 📁 Output Files

The script generates timestamped files in your chosen location:

```
system_report_hostname_YYYYMMDD_HHMMSS.html
system_report_hostname_YYYYMMDD_HHMMSS.pdf
```

### Example Output
```
system_report_webserver01_20241209_143022.html
system_report_webserver01_20241209_143022.pdf
```

## 🔐 Security Considerations

### Why Root Access is Required
- Access system hardware information
- Read security logs and configuration files
- View all running processes and services
- Access restricted system files (/proc, /sys)
- Generate comprehensive system reports

### Security Best Practices
- Run only on systems you own or have permission to audit
- Review generated reports before sharing
- Store reports securely (contain sensitive system information)
- Use appropriate file permissions on generated reports

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Permission Denied
```bash
Error: This script must be run as root or with sudo privileges.
Solution: sudo ./system_report.sh
```

#### PDF Generation Failed
```bash
Issue: ⚠ PDF generation failed, HTML report is available
Solutions:
1. Check if wkhtmltopdf is installed: which wkhtmltopdf
2. Install manually: sudo apt install wkhtmltopdf
3. Use HTML report as alternative
```

#### Command Not Found
```bash
Issue: Command not available: lscpu
Solution: Install required packages or ignore missing commands
```

#### Disk Space Issues
```bash
Issue: No space left on device
Solutions:
1. Choose /tmp directory for temporary storage
2. Clean up old reports
3. Use external storage location
```

### Verification Steps
```bash
# Check script permissions
ls -la system_report.sh

# Verify sudo access
sudo -v

# Check available disk space
df -h

# Test PDF tools
wkhtmltopdf --version
```

## 📋 Report Sections Reference

| Section | Description | Key Information |
|---------|-------------|----------------|
| 1 | Hardware | CPU, Memory, Storage, PCI/USB devices |
| 2 | Performance | System load, processes, I/O statistics |
| 3 | Network | Interfaces, routing, connections, DNS |
| 4 | Configuration | OS info, users, mount points, hostname |
| 5 | Services | Systemd services, cron jobs, daemons |
| 6 | Logging | System logs, boot messages, auth logs |
| 7 | Packages | Installed packages, recent updates |
| 8 | Security | Firewall, permissions, open ports |
| 9 | Kernel | Modules, configuration, architecture |
| 10 | Environment | Variables, locale, timezone settings |

## 🔄 Advanced Usage

### Automated Execution
```bash
# Clone the repository first
git clone https://github.com/Kelvinnambale/Bash.git

# Create automated script
cat > /etc/cron.weekly/system-report << 'EOF'
#!/bin/bash
# Automated system report generation
cd /opt/Bash
echo -e "Admin Name\nadmin@company.com\nIT Department\nCompany Inc\n*\n3\n" | sudo ./system_report1.sh
EOF

chmod +x /etc/cron.weekly/system-report
```

### Custom Report Locations
```bash
# Clone repository first
git clone https://github.com/Kelvinnambale/Bash.git
cd Bash

# Create custom report directory
sudo mkdir -p /opt/system-reports
sudo chown $(whoami):$(whoami) /opt/system-reports

# Use custom location
sudo ./system_report.sh
# Select option 4 and enter: /opt/system-reports
```

## 📞 Support and Contribution

### Repository Links
- **Main Repository**: [https://github.com/Kelvinnambale/Bash](https://github.com/Kelvinnambale/Bash)
- **Issues**: [https://github.com/Kelvinnambale/Bash/issues](https://github.com/Kelvinnambale/Bash/issues)
- **Contributions**: Fork the repository and submit pull requests

### Getting Help
- Check the troubleshooting section above
- Verify all prerequisites are met
- Ensure proper permissions and dependencies

### System Information
- **Author**: NamsTech
- **Version**: 1.0
- **License**: Open Source
- **Compatibility**: Linux distributions with Bash

### Reporting Issues
When reporting issues, include:
- Linux distribution and version
- Error messages
- System specifications
- Steps to reproduce

---

**Powered by NamsTech** - Professional Linux System Reporting
