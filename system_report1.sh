#!/bin/bash

#########################################################################
#                              NamsTech                                 #
#                 Linux System Information Report Generator             #
#########################################################################
# Usage: sudo ./system_report.sh
# Requirements: wkhtmltopdf or pandoc for PDF generation
# Must be run as root/sudo for complete system access

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables for report sections
SELECTED_SECTIONS=()
SAVE_LOCATION=""
ADMIN_NAME=""
ADMIN_EMAIL=""
DEPARTMENT=""
ORGANIZATION=""
PDF_TOOL=""

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run as root or with sudo privileges.${NC}"
        echo -e "${YELLOW}Please run: sudo $0${NC}"
        echo ""
        echo -e "${BLUE}Root access is required to:${NC}"
        echo "  - Access system hardware information"
        echo "  - Read security logs and configuration files"
        echo "  - View all running processes and services"
        echo "  - Access restricted system files"
        echo "  - Generate comprehensive system reports"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Running with administrative privileges${NC}"
}

# Check for PDF generation tools and install if missing
check_pdf_tools() {
    echo -e "${BLUE}Checking for PDF generation tools...${NC}"
    
    local has_wkhtmltopdf=false
    local has_pandoc=false
    
    if command -v wkhtmltopdf >/dev/null 2>&1; then
        has_wkhtmltopdf=true
        echo -e "${GREEN}✓ wkhtmltopdf found${NC}"
    fi
    
    if command -v pandoc >/dev/null 2>&1; then
        has_pandoc=true
        echo -e "${GREEN}✓ pandoc found${NC}"
    fi
    
    if [[ "$has_wkhtmltopdf" == false && "$has_pandoc" == false ]]; then
        echo -e "${RED}⚠ No PDF generation tools found!${NC}"
        echo -e "${YELLOW}Installing required PDF generation tools...${NC}"
        echo ""
        
        # Auto-install based on distribution
        install_pdf_tools
        
        # Re-check after installation
        if command -v wkhtmltopdf >/dev/null 2>&1; then
            has_wkhtmltopdf=true
            echo -e "${GREEN}✓ wkhtmltopdf successfully installed${NC}"
        fi
        
        if command -v pandoc >/dev/null 2>&1; then
            has_pandoc=true
            echo -e "${GREEN}✓ pandoc successfully installed${NC}"
        fi
        
        if [[ "$has_wkhtmltopdf" == false && "$has_pandoc" == false ]]; then
            echo -e "${RED}❌ Failed to install PDF generation tools automatically.${NC}"
            echo -e "${YELLOW}Please install manually and run the script again.${NC}"
            exit 1
        fi
    fi
    
    if [[ "$has_wkhtmltopdf" == true ]]; then
        PDF_TOOL="wkhtmltopdf"
        echo -e "${GREEN}✓ Will use wkhtmltopdf for PDF generation${NC}"
    elif [[ "$has_pandoc" == true ]]; then
        PDF_TOOL="pandoc"
        echo -e "${GREEN}✓ Will use pandoc for PDF generation${NC}"
    fi
    
    echo ""
}

# Auto-install PDF generation tools
install_pdf_tools() {
    echo -e "${BLUE}Detecting system and installing PDF tools...${NC}"
    
    # Detect the distribution
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        echo -e "${BLUE}Detected Debian/Ubuntu system${NC}"
        echo -e "${YELLOW}Running: apt update && apt install -y wkhtmltopdf${NC}"
        apt update >/dev/null 2>&1
        apt install -y wkhtmltopdf >/dev/null 2>&1
        
    elif [[ -f /etc/redhat-release ]]; then
        # RHEL/CentOS/Fedora
        echo -e "${BLUE}Detected RedHat/CentOS/Fedora system${NC}"
        
        if command -v dnf >/dev/null 2>&1; then
            echo -e "${YELLOW}Running: dnf install -y wkhtmltopdf${NC}"
            dnf install -y wkhtmltopdf >/dev/null 2>&1
        elif command -v yum >/dev/null 2>&1; then
            echo -e "${YELLOW}Running: yum install -y wkhtmltopdf${NC}"
            yum install -y wkhtmltopdf >/dev/null 2>&1
        fi
        
    elif [[ -f /etc/arch-release ]]; then
        # Arch Linux
        echo -e "${BLUE}Detected Arch Linux system${NC}"
        echo -e "${YELLOW}Running: pacman -S --noconfirm wkhtmltopdf${NC}"
        pacman -S --noconfirm wkhtmltopdf >/dev/null 2>&1
        
    elif [[ -f /etc/alpine-release ]]; then
        # Alpine Linux
        echo -e "${BLUE}Detected Alpine Linux system${NC}"
        echo -e "${YELLOW}Running: apk add --no-cache wkhtmltopdf${NC}"
        apk add --no-cache wkhtmltopdf >/dev/null 2>&1
        
    elif [[ -f /etc/SuSE-release ]] || [[ -f /etc/SUSE-brand ]]; then
        # openSUSE
        echo -e "${BLUE}Detected openSUSE system${NC}"
        echo -e "${YELLOW}Running: zypper install -y wkhtmltopdf${NC}"
        zypper install -y wkhtmltopdf >/dev/null 2>&1
        
    else
        echo -e "${YELLOW}Unknown distribution. Attempting generic installation...${NC}"
        
        # Try common package managers
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update >/dev/null 2>&1
            apt-get install -y wkhtmltopdf >/dev/null 2>&1
        elif command -v yum >/dev/null 2>&1; then
            yum install -y wkhtmltopdf >/dev/null 2>&1
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y wkhtmltopdf >/dev/null 2>&1
        elif command -v pacman >/dev/null 2>&1; then
            pacman -S --noconfirm wkhtmltopdf >/dev/null 2>&1
        else
            echo -e "${RED}❌ Could not detect package manager for automatic installation${NC}"
            echo ""
            echo -e "${BLUE}Manual installation required:${NC}"
            echo "  Ubuntu/Debian: sudo apt install wkhtmltopdf"
            echo "  RHEL/CentOS:   sudo yum install wkhtmltopdf"
            echo "  Fedora:        sudo dnf install wkhtmltopdf"
            echo "  Arch Linux:    sudo pacman -S wkhtmltopdf"
            echo "  Alpine:        sudo apk add wkhtmltopdf"
            echo "  openSUSE:      sudo zypper install wkhtmltopdf"
            return 1
        fi
    fi
    
    echo -e "${GREEN}✓ Installation completed${NC}"
    echo ""
}

# Function to get admin details
get_admin_details() {
    echo -e "${BLUE}Please enter Linux Administrator details:${NC}"
    echo ""
    
    read -p "Administrator Name: " ADMIN_NAME
    while [[ -z "$ADMIN_NAME" ]]; do
        echo -e "${RED}Administrator name cannot be empty.${NC}"
        read -p "Administrator Name: " ADMIN_NAME
    done
    
    read -p "Email Address: " ADMIN_EMAIL
    while [[ -z "$ADMIN_EMAIL" ]]; do
        echo -e "${RED}Email address cannot be empty.${NC}"
        read -p "Email Address: " ADMIN_EMAIL
    done
    
    read -p "Department: " DEPARTMENT
    while [[ -z "$DEPARTMENT" ]]; do
        echo -e "${RED}Department cannot be empty.${NC}"
        read -p "Department: " DEPARTMENT
    done
    
    read -p "Organization: " ORGANIZATION
    while [[ -z "$ORGANIZATION" ]]; do
        echo -e "${RED}Organization cannot be empty.${NC}"
        read -p "Organization: " ORGANIZATION
    done
    
    echo ""
    echo -e "${GREEN}Admin Details Entered:${NC}"
    echo -e "Name: $ADMIN_NAME"
    echo -e "Email: $ADMIN_EMAIL"
    echo -e "Department: $DEPARTMENT"
    echo -e "Organization: $ORGANIZATION"
    echo ""
    
    read -p "Are these details correct? [Y/n]: " confirm
    if [[ $confirm =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Please re-enter the details:${NC}"
        get_admin_details
    fi
}

# Function to display report section menu
show_section_menu() {
    clear
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                              ${BLUE}NamsTech${GREEN}                                 ║${NC}"
    echo -e "${GREEN}║              Linux System Information Report Generator               ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Select the information sections to include in your report:${NC}"
    echo ""
    echo -e "${YELLOW}  1.${NC} Hardware Information (CPU, Memory, Storage, Devices)"
    echo -e "${YELLOW}  2.${NC} Performance & Processes (System Load, Running Processes)"
    echo -e "${YELLOW}  3.${NC} Network Information (Interfaces, Routing, Connections)"
    echo -e "${YELLOW}  4.${NC} System Configuration (OS Info, Users, Mount Points)"
    echo -e "${YELLOW}  5.${NC} Service Management (Systemd Services, Cron Jobs)"
    echo -e "${YELLOW}  6.${NC} Logging & Monitoring (System Logs, Boot Messages)"
    echo -e "${YELLOW}  7.${NC} Package Management (Installed Packages, Updates)"
    echo -e "${YELLOW}  8.${NC} Security Information (Firewall, Permissions, Ports)"
    echo -e "${YELLOW}  9.${NC} Kernel Information (Modules, Configuration)"
    echo -e "${YELLOW} 10.${NC} Environment Information (Variables, Locale, Timezone)"
    echo ""
    echo -e "${GREEN}  *.${NC} Select ALL sections (Complete System Report)"
    echo -e "${RED}  0.${NC} Finish selection and continue"
    echo ""
    
    if [[ ${#SELECTED_SECTIONS[@]} -gt 0 ]]; then
        echo -e "${BLUE}Currently selected sections: ${SELECTED_SECTIONS[*]}${NC}"
        echo ""
    fi
}

# Function to handle section selection
select_sections() {
    while true; do
        show_section_menu
        read -p "Enter your choice (1-10, *, or 0 to finish): " choice
        
        case $choice in
            1|2|3|4|5|6|7|8|9|10)
                if [[ ! " ${SELECTED_SECTIONS[@]} " =~ " ${choice} " ]]; then
                    SELECTED_SECTIONS+=("$choice")
                    echo -e "${GREEN}✓ Section $choice added${NC}"
                else
                    echo -e "${YELLOW}Section $choice already selected${NC}"
                fi
                sleep 1
                ;;
            "*")
                SELECTED_SECTIONS=(1 2 3 4 5 6 7 8 9 10)
                echo -e "${GREEN}✓ All sections selected${NC}"
                sleep 1
                ;;
            0)
                if [[ ${#SELECTED_SECTIONS[@]} -eq 0 ]]; then
                    echo -e "${RED}Please select at least one section!${NC}"
                    sleep 2
                    continue
                fi
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                sleep 1
                ;;
        esac
    done
    
    # Sort the selected sections
    IFS=$'\n' SELECTED_SECTIONS=($(sort -n <<<"${SELECTED_SECTIONS[*]}"))
    unset IFS
    
    echo ""
    echo -e "${GREEN}Selected sections: ${SELECTED_SECTIONS[*]}${NC}"
    echo ""
}

# Function to get save location
get_save_location() {
    echo -e "${BLUE}Choose where to save the report:${NC}"
    echo ""
    echo -e "${YELLOW}1.${NC} Current directory ($(pwd))"
    echo -e "${YELLOW}2.${NC} /tmp directory"
    echo -e "${YELLOW}3.${NC} /var/log directory"
    echo -e "${YELLOW}4.${NC} Custom directory"
    echo ""
    
    while true; do
        read -p "Enter your choice (1-4): " location_choice
        
        case $location_choice in
            1)
                SAVE_LOCATION="$(pwd)"
                break
                ;;
            2)
                SAVE_LOCATION="/tmp"
                break
                ;;
            3)
                SAVE_LOCATION="/var/log"
                break
                ;;
            4)
                read -p "Enter custom directory path: " custom_path
                if [[ -d "$custom_path" ]]; then
                    SAVE_LOCATION="$custom_path"
                    break
                elif [[ -n "$custom_path" ]]; then
                    read -p "Directory doesn't exist. Create it? [Y/n]: " create_dir
                    if [[ ! $create_dir =~ ^[Nn]$ ]]; then
                        mkdir -p "$custom_path" && SAVE_LOCATION="$custom_path" && break
                    fi
                fi
                ;;
            *)
                echo -e "${RED}Invalid choice. Please try again.${NC}"
                ;;
        esac
    done
    
    echo -e "${GREEN}✓ Reports will be saved to: $SAVE_LOCATION${NC}"
    echo ""
}

# Function to run command safely and capture output
run_cmd() {
    local cmd="$1"
    local description="$2"
    echo -e "${YELLOW}Collecting: $description${NC}"
    
    if command -v $(echo "$cmd" | cut -d' ' -f1) >/dev/null 2>&1; then
        eval "$cmd" 2>/dev/null || echo "Command failed or permission denied"
    else
        echo "Command not available: $(echo "$cmd" | cut -d' ' -f1)"
    fi
}

# Function to safely read file
read_file() {
    local file="$1"
    if [[ -r "$file" ]]; then
        cat "$file" 2>/dev/null || echo "Unable to read file"
    else
        echo "File not accessible: $file"
    fi
}

# Function to generate HTML header
generate_html_header() {
    local report_file="$1"
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Linux System Information Report - $(hostname)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
        .header { background-color: #f4f4f4; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .section { margin-bottom: 30px; }
        .section h2 { color: #333; border-bottom: 2px solid #007acc; padding-bottom: 5px; }
        .section h3 { color: #555; margin-top: 20px; }
        pre { background-color: #f8f8f8; border: 1px solid #ddd; border-radius: 4px; padding: 10px; overflow-x: auto; font-size: 12px; }
        .info-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        .info-table th, .info-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .info-table th { background-color: #f2f2f2; }
        .timestamp { text-align: right; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔧 NamsTech - Linux System Information Report</h1>
        <table class="info-table">
            <tr><th>System Hostname</th><td>$(hostname)</td></tr>
            <tr><th>Report Generated</th><td>$(date)</td></tr>
            <tr><th>Linux Administrator</th><td>$ADMIN_NAME</td></tr>
            <tr><th>Email</th><td>$ADMIN_EMAIL</td></tr>
            <tr><th>Department</th><td>$DEPARTMENT</td></tr>
            <tr><th>Organization</th><td>$ORGANIZATION</td></tr>
            <tr><th>Selected Sections</th><td>${SELECTED_SECTIONS[*]}</td></tr>
            <tr><th>Generated By</th><td><strong>NamsTech System Report Tool</strong></td></tr>
        </table>
    </div>
EOF
}

# Function to generate each section
generate_section() {
    local section_num="$1"
    local report_file="$2"
    
    case $section_num in
        1)
            echo "Collecting Hardware Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>1. System Hardware Information</h2>
        
        <h3>CPU Information</h3>
        <pre>$(run_cmd "lscpu" "CPU Details")</pre>
        
        <h3>CPU Info from /proc/cpuinfo</h3>
        <pre>$(read_file "/proc/cpuinfo" | head -30)</pre>
        
        <h3>Memory Information</h3>
        <pre>$(run_cmd "free -h" "Memory Usage")</pre>
        
        <h3>Detailed Memory Info</h3>
        <pre>$(read_file "/proc/meminfo" | head -20)</pre>
        
        <h3>Storage Information</h3>
        <pre>$(run_cmd "lsblk" "Block Devices")</pre>
        
        <h3>Disk Usage</h3>
        <pre>$(run_cmd "df -h" "Filesystem Usage")</pre>
        
        <h3>Hardware Overview</h3>
        <pre>$(run_cmd "lshw -short" "Hardware Summary")</pre>
        
        <h3>PCI Devices</h3>
        <pre>$(run_cmd "lspci" "PCI Devices")</pre>
        
        <h3>USB Devices</h3>
        <pre>$(run_cmd "lsusb" "USB Devices")</pre>
        
        <h3>DMI Information</h3>
        <pre>$(run_cmd "dmidecode -t system" "System DMI Info")</pre>
    </div>
EOF
            ;;
        2)
            echo "Collecting Performance Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>2. System Performance and Processes</h2>
        
        <h3>System Uptime and Load</h3>
        <pre>$(run_cmd "uptime" "System Uptime")</pre>
        
        <h3>Load Average</h3>
        <pre>$(read_file "/proc/loadavg")</pre>
        
        <h3>Currently Logged Users</h3>
        <pre>$(run_cmd "w" "Logged Users")</pre>
        
        <h3>Running Processes (Top 20)</h3>
        <pre>$(run_cmd "ps aux --sort=-%cpu | head -20" "Top CPU Processes")</pre>
        
        <h3>Process Tree</h3>
        <pre>$(run_cmd "pstree" "Process Tree")</pre>
        
        <h3>Memory Usage by Process</h3>
        <pre>$(run_cmd "ps aux --sort=-%mem | head -15" "Top Memory Processes")</pre>
        
        <h3>I/O Statistics</h3>
        <pre>$(run_cmd "iostat -x 1 2" "I/O Stats")</pre>
        
        <h3>Virtual Memory Statistics</h3>
        <pre>$(run_cmd "vmstat 1 3" "VM Stats")</pre>
    </div>
EOF
            ;;
        3)
            echo "Collecting Network Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>3. Network Information</h2>
        
        <h3>Network Interfaces</h3>
        <pre>$(run_cmd "ip addr show" "Network Interfaces")</pre>
        
        <h3>Routing Table</h3>
        <pre>$(run_cmd "ip route show" "Routing Table")</pre>
        
        <h3>Network Connections</h3>
        <pre>$(run_cmd "ss -tuln" "Network Connections")</pre>
        
        <h3>Listening Services</h3>
        <pre>$(run_cmd "ss -tulpn" "Listening Services")</pre>
        
        <h3>Network Statistics</h3>
        <pre>$(run_cmd "netstat -i" "Interface Statistics")</pre>
        
        <h3>DNS Configuration</h3>
        <pre>$(read_file "/etc/resolv.conf")</pre>
        
        <h3>Hosts File</h3>
        <pre>$(read_file "/etc/hosts")</pre>
    </div>
EOF
            ;;
        4)
            echo "Collecting System Configuration..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>4. System Configuration</h2>
        
        <h3>System Information</h3>
        <pre>$(run_cmd "uname -a" "System Info")</pre>
        
        <h3>OS Release Information</h3>
        <pre>$(read_file "/etc/os-release")</pre>
        
        <h3>LSB Release</h3>
        <pre>$(run_cmd "lsb_release -a" "LSB Release")</pre>
        
        <h3>Hostname Configuration</h3>
        <pre>$(read_file "/etc/hostname")</pre>
        
        <h3>Filesystem Mount Configuration</h3>
        <pre>$(read_file "/etc/fstab")</pre>
        
        <h3>Currently Mounted Filesystems</h3>
        <pre>$(read_file "/proc/mounts")</pre>
        
        <h3>User Accounts (partial)</h3>
        <pre>$(run_cmd "getent passwd | grep -E '/(bin/bash|bin/sh)$' | head -10" "User Accounts")</pre>
        
        <h3>Group Information (first 10)</h3>
        <pre>$(run_cmd "getent group | head -10" "Groups")</pre>
        
        <h3>Sudo Configuration</h3>
        <pre>$(run_cmd "cat /etc/sudoers | grep -v '^#' | grep -v '^$'" "Sudo Config")</pre>
    </div>
EOF
            ;;
        5)
            echo "Collecting Service Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>5. Service Management</h2>
        
        <h3>Systemd Services Status</h3>
        <pre>$(run_cmd "systemctl list-units --type=service --state=running" "Running Services")</pre>
        
        <h3>Failed Services</h3>
        <pre>$(run_cmd "systemctl list-units --type=service --state=failed" "Failed Services")</pre>
        
        <h3>Enabled Services</h3>
        <pre>$(run_cmd "systemctl list-unit-files --type=service --state=enabled | head -20" "Enabled Services")</pre>
        
        <h3>Cron Jobs</h3>
        <pre>$(run_cmd "crontab -l" "User Cron Jobs")</pre>
        <pre>$(read_file "/etc/crontab")</pre>
    </div>
EOF
            ;;
        6)
            echo "Collecting Log Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>6. Logging and Monitoring</h2>
        
        <h3>Recent System Messages (last 20 lines)</h3>
        <pre>$(run_cmd "journalctl -n 20 --no-pager" "Recent Logs")</pre>
        
        <h3>Boot Messages (last 30 lines)</h3>
        <pre>$(run_cmd "dmesg | tail -30" "Boot Messages")</pre>
        
        <h3>Authentication Logs (last 15 lines)</h3>
        <pre>$(run_cmd "tail -15 /var/log/auth.log" "Auth Logs")</pre>
        
        <h3>System Log Files</h3>
        <pre>$(run_cmd "ls -la /var/log/ | head -20" "Log Files")</pre>
        
        <h3>Recent Login History</h3>
        <pre>$(run_cmd "last -10" "Login History")</pre>
    </div>
EOF
            ;;
        7)
            echo "Collecting Package Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>7. Package Management</h2>
        
        <h3>Installed Packages Count</h3>
EOF
            # Detect package manager and show appropriate info
            if command -v dpkg >/dev/null 2>&1; then
                cat >> "$report_file" << EOF
        <pre>$(run_cmd "dpkg -l | wc -l" "Package Count (dpkg)")</pre>
        
        <h3>Recently Installed Packages (last 10)</h3>
        <pre>$(run_cmd "grep 'install ' /var/log/dpkg.log | tail -10" "Recent Installs")</pre>
EOF
            elif command -v rpm >/dev/null 2>&1; then
                cat >> "$report_file" << EOF
        <pre>$(run_cmd "rpm -qa | wc -l" "Package Count (rpm)")</pre>
        
        <h3>Recently Installed Packages (last 10)</h3>
        <pre>$(run_cmd "rpm -qa --last | head -10" "Recent Installs")</pre>
EOF
            fi
            cat >> "$report_file" << EOF
    </div>
EOF
            ;;
        8)
            echo "Collecting Security Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>8. Security Information</h2>
        
        <h3>Open Ports and Services</h3>
        <pre>$(run_cmd "ss -tulpn" "Open Ports")</pre>
        
        <h3>Firewall Status</h3>
        <pre>$(run_cmd "ufw status" "UFW Status")</pre>
        <pre>$(run_cmd "iptables -L -n" "IPTables Rules")</pre>
        
        <h3>SELinux Status (if available)</h3>
        <pre>$(run_cmd "sestatus" "SELinux Status")</pre>
        
        <h3>File Permissions on Critical Files</h3>
        <pre>$(run_cmd "ls -la /etc/passwd /etc/shadow /etc/group /etc/sudoers" "Critical File Perms")</pre>
    </div>
EOF
            ;;
        9)
            echo "Collecting Kernel Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>9. Kernel and Module Information</h2>
        
        <h3>Kernel Version</h3>
        <pre>$(read_file "/proc/version")</pre>
        
        <h3>Kernel Command Line</h3>
        <pre>$(read_file "/proc/cmdline")</pre>
        
        <h3>Loaded Kernel Modules</h3>
        <pre>$(run_cmd "lsmod | head -20" "Loaded Modules")</pre>
        
        <h3>Kernel Configuration (if available)</h3>
        <pre>$(run_cmd "ls -la /boot/config-*" "Kernel Config Files")</pre>
        
        <h3>System Architecture</h3>
        <pre>$(run_cmd "arch" "Architecture")</pre>
    </div>
EOF
            ;;
        10)
            echo "Collecting Environment Information..."
            cat >> "$report_file" << EOF
    <div class="section">
        <h2>10. Environment Information</h2>
        
        <h3>Environment Variables</h3>
        <pre>$(run_cmd "env | sort" "Environment Variables")</pre>
        
        <h3>Path Information</h3>
        <pre>$(echo $PATH | tr ':' '\n')</pre>
        
        <h3>Timezone Information</h3>
        <pre>$(run_cmd "timedatectl" "Time/Date Settings")</pre>
        
        <h3>Locale Information</h3>
        <pre>$(run_cmd "locale" "Locale Settings")</pre>
    </div>
EOF
            ;;
    esac
}

# Function to generate HTML footer
generate_html_footer() {
    local report_file="$1"
    cat >> "$report_file" << EOF
    
    <div class="timestamp">
        <p>Report generated on $(date) by $ADMIN_NAME | <strong>Powered by NamsTech</strong></p>
    </div>
</body>
</html>
EOF
}

# Main execution function
main() {
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                              ${BLUE}NamsTech${GREEN}                                 ║${NC}"
    echo -e "${GREEN}║              Linux System Information Report Generator               ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Check for root privileges first
    check_root

    # Check for PDF generation tools
    check_pdf_tools

    # Get admin details from user input
    get_admin_details

    # Select report sections
    select_sections

    # Get save location
    get_save_location

    # Generate file names with timestamp
    local timestamp="$(date +%Y%m%d_%H%M%S)"
    local report_file="${SAVE_LOCATION}/system_report_$(hostname)_${timestamp}.html"
    local pdf_file="${SAVE_LOCATION}/system_report_$(hostname)_${timestamp}.pdf"

    echo -e "${BLUE}Generating report for $(hostname)...${NC}"
    echo -e "${BLUE}Report will be saved to: ${SAVE_LOCATION}${NC}"
    echo ""

    # Generate HTML header
    generate_html_header "$report_file"

    # Generate selected sections
    for section in "${SELECTED_SECTIONS[@]}"; do
        generate_section "$section" "$report_file"
    done

    # Generate HTML footer
    generate_html_footer "$report_file"

    echo -e "${GREEN}HTML report generated: $report_file${NC}"

    # Generate PDF based on available tool
    echo -e "${BLUE}Generating PDF report...${NC}"
    if [[ "$PDF_TOOL" == "wkhtmltopdf" ]]; then
        wkhtmltopdf --page-size A4 --margin-top 0.75in --margin-right 0.75in --margin-bottom 0.75in --margin-left 0.75in "$report_file" "$pdf_file" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✓ PDF report generated using wkhtmltopdf: $pdf_file${NC}"
        else
            echo -e "${YELLOW}⚠ PDF generation failed, HTML report is available${NC}"
        fi
    elif [[ "$PDF_TOOL" == "pandoc" ]]; then
        pandoc "$report_file" -o "$pdf_file" --pdf-engine=wkhtmltopdf 2>/dev/null || pandoc "$report_file" -o "$pdf_file" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}✓ PDF report generated using pandoc: $pdf_file${NC}"
        else
            echo -e "${YELLOW}⚠ PDF generation failed, HTML report is available${NC}"
        fi
    fi

    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    REPORT GENERATION COMPLETED                       ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Report Summary:${NC}"
    echo -e "  • System: $(hostname)"
    echo -e "  • Administrator: $ADMIN_NAME"
    echo -e "  • Sections included: ${SELECTED_SECTIONS[*]}"
    echo -e "  • Save location: $SAVE_LOCATION"
    echo ""
    echo -e "${BLUE}Files generated:${NC}"
    echo -e "  • HTML Report: $(basename "$report_file")"
    if [[ -f "$pdf_file" ]]; then
        echo -e "  • PDF Report:  $(basename "$pdf_file")"
    fi
    echo ""
    echo -e "${CYAN}Section Reference:${NC}"
    echo -e "  1=Hardware, 2=Performance, 3=Network, 4=Configuration"
    echo -e "  5=Services, 6=Logging, 7=Packages, 8=Security"
    echo -e "  9=Kernel, 10=Environment"
    echo ""
    echo -e "${YELLOW}Usage: sudo ./system_report.sh${NC}"
    echo -e "${YELLOW}The script requires root privileges and PDF tools for complete functionality.${NC}"
}

# Script execution starts here
main "$@"