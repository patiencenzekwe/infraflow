# INFRAFLOW - SYSTEM HEALTH CHECK

# 📋 Overview
# InfraFlow System Health Check is a Bash script designed to monitor the health of your Linux system. It provides a comprehensive report including uptime, memory usage, disk usage, CPU load, top processes, network info, and critical services status.

# 🛠️ Prerequisites
## Linux system with Bash shell
## Basic tools: bash, uptime, free, df, lscpu, ps, ip, and systemctl (for service checks)
## Permissions to read system info and write logs

# 🚀 How to Run
## From the project root directory, run: bash scripts/system_health/system_health_check.sh
# The script will generate a detailed report on the system's health and save logs in the logs/ directory.

# 📁 Location
## Script path: scripts/system_health/system_health_check.sh
## Logs path: logs/ (auto-created by the script)

# 🧾 Output
## The script outputs a summary report to the console with color-coded alerts.
## A full detailed log file is saved with a timestamp in the logs/ folder.

# 📌 Notes
## High memory, disk usage, or system load will trigger warnings or critical alerts.
## The script checks for common critical services and reports their status.
## Suitable for Linux servers or VMs to quickly assess system health.


