#!/bin/bash
# Waybar custom module script for NordVPN status
# Returns JSON with text, tooltip, and class for styling

status=$(nordvpn status 2>/dev/null)

if echo "$status" | grep -qi "status: connected"; then
  server=$(echo "$status" | grep -i "server:" | awk -F': ' '{print $2}' | sed 's/\..*//') # short server name
  city=$(echo "$status" | grep -i "city:" | awk -F': ' '{print $2}')
  country=$(echo "$status" | grep -i "country:" | awk -F': ' '{print $2}')
  echo "{\"text\": \"󰌆\", \"tooltip\": \"VPN: ${city}, ${country}\\n${server}\", \"class\": \"connected\"}"
else
  echo "{\"text\": \"󰌊\", \"tooltip\": \"VPN: Disconnected\", \"class\": \"disconnected\"}"
fi
