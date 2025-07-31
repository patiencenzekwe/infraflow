#!/bin/bash

# InfraFlow System Health Check
# Purpose: Comprehensive system monitoring with logging
# Author: Patience - Cloud DevOps Engineer
# Version: 1.0

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create logs directory if it doesn't exist
mkdir -p ../../logs

# Create up logging with absolute path handling
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../../logs/system_health_$(date +%Y%m%d_%H%M%S).log'
SCRIPT_NAME=$(basename "$0")

# Function to log both to console and file with colors
log_output() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function for colored console output only
console_output() {
    echo -e "$1"
}

# Header
log_output "================================"
log_output "🩺 INFRAFLOW SYSTEM HEALTH CHECK"
log_output "================================="
log_output "🕒 Generated: $(date)"
log_output "🖥️ Host: $(hostname)"
log_output "👤 User: $(whoami)"
log_output "📁 Log File: $LOG_FILE"
log_output ""

# System Uptime
log_output "🕒 System Uptime:"
uptime | tee -a "$LOG_FILE"
log_output ""

# Memory Usage
log_output "💾 Memory Usage:"
free -h | tee -a "$LOG_FILE"
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')

if [ "$MEMORY_USAGE" -gt 90 ]; then
    log_output "🚨 CRITICAL: Very high memory usage detected ($MEMORY_USAGE%)"
    console_output "${RED}🚨 CRITICAL: Very high memory usage detected ($MEMORY_USAGE%)${NC}"
elif [ "$MEMORY_USAGE" -gt 80 ]; then
    log_output "⚠️ WARNING: High memory usage detected ($MEMORY_USAGE%)"
    console_output "${YELLOW}⚠️ WARNING: High memory usage detected ($MEMORY_USAGE%)${NC}"
else
    log_output "✅ Memory usage normal ($MEMORY_USAGE%)"
    console_output "${GREEN}✅ Memory usage normal ($MEMORY_USAGE%)${NC}"
fi
log_output ""

# Disk Usage
log_output "📦 Disk Usage"
df -h | tee -a "$LOG_FILE"
HIGH_DISK=$(dh -h | awk 'NR>1 && $5+0 > 80 {print $5 " on " $6}')
CRITICAL_DISK=$(df -h | awk 'NR>1 && $5+0 > 95 {print $5 " on " $6}')

if [ -n "$CRITICAL_DISK"]; then
    log_output "🚨 CRITICAL: Very high disk usage detected:"
    log_output "$CRITICAL_DISK"
    console_output "${RED}🚨 CRITICAL: Very high disk usage detected: ${NC}"
    console_output "${RED}$CRITICAL_DISK${NC}"
elif [ -n "$HIGH_DISK" ]; then
    log_output "⚠️ WARNING: High disk usage detected:"
    log_output "$HIGH_DISK"
    console_output "${YELLOW}⚠️ WARNING: High disk usage detected:${NC}"
    console_output "${YELLOW}$HIGH_DISK${NC}"
else
    log_output "✅ Disk usage normal"
    console_output "${GREEN}✅ Disk usage normal${NC}"
fi
log_output ""

# CPU Info
log_output "🔥 CPU Infomation:"
CPU_MODEL=$(lscpu | grep 'Model name' | cut -d: f2 | xargs)
CPU_CORES=$(nproc)
LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')

log_output "CPU Model: $CPU_MODEL"
log_output "CPU Cores: $CPU_CORES"
log_output "Load Average (1min): $LOAD_AVG"

if (($(echo "$LOAD_AVG > $CPU_CORES" | bc -l) )); then
    log_output "⚠️ WARNING: High system load ($LOAD_AVG on $CPU_CORES cores)"
    console_output "${YELLOW}⚠️ WARNING: High system load ($LOAD_AVG on $CPU_CORES cores)${NC}"
else
    log_output "✅ System load normal"
    console_output "${GREEN}✅ System load normal${NC}"
fi
log_output ""

# Top Processes
log_output "📝 tOP 5 Processes by Memory:"
ps aux --sort=-%cpu | head -n 6 | tee -a "$LOG_FILE"
log_output ""

log_output "🔝 Top 5 Processes by CPU:"
ps aux --sort=-%mem | head -n 6 | tee -a "$LOG_FILE"
log_output ""

# Network Info
log_output "🛜 Network Information:"
ip a | grep inet | grep -v 127.0.0.1 | tee -a "$LOG_FILE"
log_output ""

# Critical Services Check
if command -v systemctl &> /dev/null; then
    log_output "🔍 Critical Services Status:"
    services=("ssh" "networking" "systemd-resolved" "cron")
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service"; then
            log_output "✅ $service: RUNNING"
        else
            if systemctl list-unit-files | grep -q "^$service"; then
                log_output "❌ $service: NOT RUNNING"
                console_output "${RED}❌ $SERVICE: NOT RUNNING${NC}"
            fi
        fi
    done
    log_output ""
fi

# Summary
log_output "📊 HEALTH CHECK SUMMARY:"
log_output "========================"
ALERT=0

if [ "$MEMORY_USAGE" -gt 80 ]; then
    log_output "🔴 Memory usage: $MEMORY_USAGE% (High)"
    ((ALERTS++))
fi
if [ -n "$HIGH_DISK" ]; then
    log_output "🔴 Disk usage: High on some partitions"
    ((ALERTS++))
fi
if (( $(echo "$LOAD_AVG > $CPU_CORES" | bc -l) )); then
    log_output "🔴 System load: $LOAD_AVG (High for $CPU_CORES cores)"
    ((ALERTS++))
fi

if [ $ALERTS -eq 0 ]; then
    log_output "🟢 All systems operating normally"
    console_output "${GREEN}🟢 All systems operating normally${NC}"
else
    log_output "🟡 $ALERTS alert(s) detected - review above"
    console_output "${YELLOW}🟡 $ALERTS alert(s) detected - review above"
fi

log_output ""
log_output "✅ Health Check Complete!"
log_output "📄 Full report saved to: $LOG_FILE"
log_output "🕒 Completed: $(date)"
log_output "==============================="

# Final console summary
console_output ""
console_output "${BLUE}📊 Infraflow Health Check Summary;${NC}"
console_output "${BLUE} Memory: $MEMORY_USAGE% | Load: $LOAD_AVG | Alerts: $ALERTS${NC}"
console_output "${BLUE} Report: $LOG_FILE${NC}"

exit $ALERTS
