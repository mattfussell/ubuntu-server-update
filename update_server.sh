#!/bin/bash
# Purpose:
#   Keep the server up to date with minimal
#   user intervention
# Environment:
#   Ubuntu Server
# Required packages:
#   aptitude
if ! command -v aptitude > /dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y aptitude
fi

# set variables
temp="/home/[ your user name here ]/update.tmp"
log="/home/[ your user name here ]/update.log"
trimmed="/home/[ your user name here ]/update.trim"

# Create a new entry in the update log
echo "" >> "$temp"
echo "-----" >> "$temp"
date >> "$temp"
echo "-----" >> "$temp"
echo >> "$temp"

# Update repositories
apt-get update >> "$temp" 2>&1

# Upgrade server software
aptitude safe-upgrade -y >> "$temp" 2>&1

# Clean up packages
apt-get autoclean -y >> "$temp" 2>&1
apt-get autoremove -y >> "$temp" 2>&1

# Log the reboot
echo "-----" >> "$temp"
echo "rebooting..." >> "$temp"

# If the log file doesn't exist, create the
# file to merge with the temp file to create
# the log. Otherwise, truncate the log to
# 2500 lines and save that as the file to be
# merged.
if [ ! -f "$log" ]; then
  touch "$trimmed"
else
  tail -n 2500 "$log" > "$trimmed"
  rm "$log"
fi

# Merge the latest update activities and the
# truncated existing log files into a new
# log file, then remove the temporary files
cat "$temp" >> "$log"
cat "$trimmed" >> "$log"
rm "$temp" && rm "$trimmed"

# Reboot the server
reboot
