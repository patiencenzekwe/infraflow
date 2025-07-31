#!/bin/bash

echo "============================="
echo "🩺 SYSTEM HEALTH CHECK REPORT"
echo "============================="

echo -e "\n🕒 Uptime:"
uptime

echo -e "\n💾 Memory Usage:"
free -h

echo -e "\n💿 Disk Usage:"
df -h

echo -e"n🔥 Top 5 Processes by Memory:"
ps aux --sort=-%mem | head -n 6

echo -e "\🛜 Network Indo:"
ip a | grep inet | grep -v 127.0.0.1

echo -e "\n✅ Report Complete."

