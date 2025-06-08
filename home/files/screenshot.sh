#!/usr/bin/env sh

#!/bin/bash

# Wayland Screenshot Script with Rofi
# Dependencies: rofi, grim, slurp, wl-clipboard (optional)

# Screenshot directory
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with timestamp
FILENAME="screenshot-$(date +%Y%m%d-%H%M%S).png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"

# Rofi options
OPTIONS="📱 Screen\n🪟 Window\n🔲 Region\n❌ Cancel"

ROFI_CMD="rofi -location 3 -no-fixed-num-lines -lines 4"
# Show rofi menu and get selection
export INPUT=false
CHOICE=$(echo -e "$OPTIONS" | $ROFI_CMD -dmenu -p "Screenshot:" -scrollbar-width)

case "$CHOICE" in
    "📱 Screen")
        # Full screen screenshot
        grim "$FILEPATH"
        STATUS="Full screen"
        ;;
    "🪟 Window")
        # Window screenshot
        # Use slurp to select window
        WINDOW=$(hyprctl clients -j | jq -r '.[] | select(.mapped == true) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp -f "%x,%y %wx%h")
        if [ -n "$WINDOW" ]; then
            grim -g "$WINDOW" "$FILEPATH"
            STATUS="Window"
        else
            echo "No window selected"
            exit 1
        fi
        ;;
    "🔲 Region")
        # Region screenshot
        REGION=$(slurp)
        if [ -n "$REGION" ]; then
            grim -g "$REGION" "$FILEPATH"
            STATUS="Region"
        else
            echo "No region selected"
            exit 1
        fi
        ;;
    "❌ Cancel"|"")
        echo "Screenshot cancelled"
        exit 0
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

# Check if screenshot was taken successfully
if [ -f "$FILEPATH" ]; then
    # Copy to clipboard (optional - requires wl-clipboard)
    if command -v wl-copy &> /dev/null; then
        wl-copy < "$FILEPATH"
        CLIPBOARD_MSG=" (copied to clipboard)"
    else
        CLIPBOARD_MSG=""
    fi
    
    # Show notification (optional - requires notify-send)
    if command -v notify-send &> /dev/null; then
        notify-send "Screenshot" "$STATUS screenshot saved to $FILENAME$CLIPBOARD_MSG" -i "$FILEPATH"
    fi
    
    echo "$STATUS screenshot saved: $FILEPATH"
else
    echo "Failed to take screenshot"
    exit 1
fi
