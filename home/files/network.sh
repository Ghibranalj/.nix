#!/usr/bin/env sh

# Custom Waybar Network Module
# Shows WiFi strength + SSID or Ethernet icon

get_network_info() {
    ipaddr=$(ip route  | grep default | awk '{ print $9}')
    # Check for active ethernet connection
    ethernet_device=$(ip route | grep default | grep -E 'eth|enp|eno' | head -n1 | awk '{print $5}')
    
    if [[ -n "$ethernet_device" ]]; then
        # Ethernet connection active
        cat << EOF
{"text": "모", "class": "ethernet", "tooltip": "Ethernet Connected. IP: $ipaddr"}
EOF
        return
    fi
    
    # Check for WiFi connection
    wifi_device=$(iwconfig 2>/dev/null | grep -E '^wl|^wlan' | head -n1 | cut -d' ' -f1)
    
    if [[ -z "$wifi_device" ]]; then
        echo '{"text": "󰤭", "class": "disconnected", "tooltip": "No Connection"}'
        return
    fi
    
    # Get WiFi info
    wifi_info=$(iwconfig "$wifi_device" 2>/dev/null)
    
    # Check if connected to WiFi
    if echo "$wifi_info" | grep -q "Not-Associated\|off/any"; then
        echo '{"text": "󰤭", "class": "disconnected", "tooltip": "WiFi Disconnected"}'
        return
    fi
    
    # Get SSID
    ssid=$(echo "$wifi_info" | grep -o 'ESSID:"[^"]*"' | cut -d'"' -f2)
    if [[ -z "$ssid" ]]; then
        ssid="Unknown"
    fi
    
    # Get signal strength
    signal_level=$(echo "$wifi_info" | grep -o 'Signal level=[0-9-]* dBm' | grep -o '[0-9-]*' | head -n1)
    
    if [[ -z "$signal_level" ]]; then
        # Try alternative method
        signal_level=$(cat "/proc/net/wireless" 2>/dev/null | grep "$wifi_device" | awk '{print $3}' | cut -d'.' -f1)
        if [[ -n "$signal_level" && "$signal_level" -gt 0 ]]; then
            # Convert link quality to approximate dBm
            signal_level=$((signal_level - 110))
        fi
    fi
    
    # Determine WiFi icon based on signal strength
    if [[ -n "$signal_level" ]]; then
        if [[ "$signal_level" -ge -30 ]]; then
            wifi_icon="󰤨"  # Excellent
        elif [[ "$signal_level" -ge -50 ]]; then
            wifi_icon="󰤥"  # Good
        elif [[ "$signal_level" -ge -70 ]]; then
            wifi_icon="󰤢"  # Fair
        elif [[ "$signal_level" -ge -80 ]]; then
            wifi_icon="󰤟"  # Weak
        else
            wifi_icon="󰤯"  # Very weak
        fi
    else
        wifi_icon="󰤨"  # Default to full if can't determine
    fi
    
    # Format output
    text="${wifi_icon} ${ssid}"
    tooltip="WiFi: ${ssid}"
    if [[ -n "$signal_level" ]]; then
        tooltip="${tooltip} (${signal_level} dBm)"
    fi
    tooltip="${tooltip}. IP: ${ipaddr}"
    
    cat <<EOF
{"text": "${text}", "class": "wifi", "tooltip": "${tooltip}"}"
EOF
}

# Main execution
get_network_info
