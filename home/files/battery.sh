#!/usr/bin/env sh

# Waybar custom battery module script
# Returns empty JSON if no battery is detected

BATTERY_PATH="/sys/class/power_supply"
BATTERY_DIRS=($(find "$BATTERY_PATH" -name "BAT*" 2>/dev/null))

# Check if any battery directories exist
if [ ${#BATTERY_DIRS[@]} -eq 0 ]; then
    # No battery found - return empty JSON for Waybar
    echo '{"text": "", "tooltip": "", "class": "", "percentage": 0}'
    exit 0
fi

# Use the first battery found
BATTERY_DIR="${BATTERY_DIRS[0]}"
BATTERY_NAME=$(basename "$BATTERY_DIR")

# Check if required files exist
if [[ ! -f "$BATTERY_DIR/capacity" ]] || [[ ! -f "$BATTERY_DIR/status" ]]; then
    echo '{"text": "", "tooltip": "", "class": "", "percentage": 0}'
    exit 0
fi

# Read battery information
CAPACITY=$(cat "$BATTERY_DIR/capacity" 2>/dev/null || echo "0")
STATUS=$(cat "$BATTERY_DIR/status" 2>/dev/null || echo "Unknown")

# Validate capacity is a number
if ! [[ "$CAPACITY" =~ ^[0-9]+$ ]]; then
    CAPACITY=0
fi

# Determine battery icon based on capacity and status
get_battery_icon() {
    local cap=$1
    local stat=$2
    
    if [[ "$stat" == "Charging" ]]; then
        echo "󰂄"  # Charging icon
    elif [[ $cap -ge 90 ]]; then
        echo "󰁹"  # Full battery
    elif [[ $cap -ge 80 ]]; then
        echo "󰂂"  # High battery
    elif [[ $cap -ge 60 ]]; then
        echo "󰂀"  # Medium-high battery
    elif [[ $cap -ge 40 ]]; then
        echo "󰁾"  # Medium battery
    elif [[ $cap -ge 20 ]]; then
        echo "󰁼"  # Low battery
    else
        echo "󰁺"  # Critical battery
    fi
}

# Determine CSS class based on capacity
get_battery_class() {
    local cap=$1
    local stat=$2
    
    if [[ "$stat" == "Charging" ]]; then
        echo "charging"
    elif [[ $cap -le 15 ]]; then
        echo "critical"
    elif [[ $cap -le 30 ]]; then
        echo "warning"
    else
        echo "normal"
    fi
}

# Get additional battery info for tooltip
get_battery_tooltip() {
    local cap=$1
    local stat=$2
    local name=$3
    
    local tooltip="$name: $cap% ($stat)"
    
    # Add time remaining if available
    if [[ -f "$BATTERY_DIR/time_to_empty_now" ]] && [[ "$stat" == "Discharging" ]]; then
        local time_minutes=$(cat "$BATTERY_DIR/time_to_empty_now" 2>/dev/null)
        if [[ -n "$time_minutes" ]] && [[ "$time_minutes" -gt 0 ]]; then
            local hours=$((time_minutes / 60))
            local mins=$((time_minutes % 60))
            tooltip="$tooltip\nTime remaining: ${hours}h ${mins}m"
        fi
    elif [[ -f "$BATTERY_DIR/time_to_full_now" ]] && [[ "$stat" == "Charging" ]]; then
        local time_minutes=$(cat "$BATTERY_DIR/time_to_full_now" 2>/dev/null)
        if [[ -n "$time_minutes" ]] && [[ "$time_minutes" -gt 0 ]]; then
            local hours=$((time_minutes / 60))
            local mins=$((time_minutes % 60))
            tooltip="$tooltip\nTime to full: ${hours}h ${mins}m"
        fi
    fi
    
    echo "$tooltip"
}

# Generate output
ICON=$(get_battery_icon "$CAPACITY" "$STATUS")
CLASS=$(get_battery_class "$CAPACITY" "$STATUS")
TOOLTIP=$(get_battery_tooltip "$CAPACITY" "$STATUS" "$BATTERY_NAME")

# Output JSON for Waybar
cat << EOF
{ "text": "$ICON $CAPACITY%", "alt": "$ICON $CAPACITY%", "tooltip": "$TOOLTIP", "class": "$CLASS", "percentage": $CAPACITY }
EOF
