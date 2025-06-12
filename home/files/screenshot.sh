#!/usr/bin/env sh
# Wayland Screenshot/Record Script with Rofi
# Dependencies: rofi, grim, slurp, wf-recorder, wl-clipboard (optional)

export INPUT=false
ROFI_CMD="rofi -location 3 -no-fixed-num-lines"

# Screenshot directory
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Generate filename with timestamp
generate_filename() {
    if [ "$MODE" = "record" ]; then
        echo "recording-$(date +%Y%m%d-%H%M%S).mp4"
    else
        echo "screenshot-$(date +%Y%m%d-%H%M%S).png"
    fi
}

record() {
    local file="$1"
    wf-recorder -f "$file" &
    RECORDER_PID=$!
    export INPUT=false
    notify-send "🛑 Stop Recording" --urgency=critical --expire-time=0 -w
    kill $RECORDER_PID
}

SCREEN="📱 Screen"
WINDOW="🪟 Window"
REGION="🔲 Region"
ADD_DELAY="➕ Add Delay"
CANCEL="❌ Cancel"
TOGGLE_MODE="🔄 Toggle Mode"

# Rofi options
OPTIONS="$SCREEN\n$WINDOW\n$REGION\n$ADD_DELAY\n$TOGGLE_MODE\n$CANCEL"

# Show rofi menu and get selection
DELAY_SECONDS=0
MODE="screenshot"

while true; do
CHOICE=$(echo -e "$OPTIONS" "\nDelay: ${DELAY_SECONDS}s, Mode: ${MODE}" | $ROFI_CMD -dmenu -p "Screenshot/Record:" -scrollbar-width)

# if exit code is not 0, exit
if [ $? -ne 0 ]; then
    exit 0
fi

case "$CHOICE" in
    $ADD_DELAY)
        DELAY_SECONDS=$((DELAY_SECONDS + 1))
        echo "Delay increased to ${DELAY_SECONDS}s" 1>&2
        ;;
    $TOGGLE_MODE)
        if [ "$MODE" = "screenshot" ]; then
            MODE="record"
            echo "Switched to record mode"
        else
            MODE="screenshot"
            echo "Switched to screenshot mode"
        fi
        continue
        ;;
    $SCREEN)
        FILENAME=$(generate_filename)
        FILEPATH="$SCREENSHOT_DIR/$FILENAME"
        sleep $DELAY_SECONDS
        
        if [ "$MODE" = "record" ]; then
            # Full screen recording
            record "$FILEPATH" 
        else
            # Full screen screenshot
            grim "$FILEPATH"
            STATUS="Full screen"
        fi
        break
        ;;
    $WINDOW)
        FILENAME=$(generate_filename)
        FILEPATH="$SCREENSHOT_DIR/$FILENAME"
        
        # Use slurp to select window
        WINDOW=$(hyprctl clients -j | jq -r '.[] | select(.mapped == true) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp -f "%x,%y %wx%h")
        sleep $DELAY_SECONDS
        
        if [ -n "$WINDOW" ]; then
            if [ "$MODE" = "record" ]; then
                record "$FILEPATH" 
            else
                grim -g "$WINDOW" "$FILEPATH"
                STATUS="Window"
            fi
        else
            echo "No window selected"
            exit 1
        fi
        break
        ;;
    $REGION)
        FILENAME=$(generate_filename)
        FILEPATH="$SCREENSHOT_DIR/$FILENAME"
        
        # Region selection
        REGION=$(slurp)
        sleep $DELAY_SECONDS
        
        if [ -n "$REGION" ]; then
            if [ "$MODE" = "record" ]; then
                record "$FILEPATH" 
            else
                grim -g "$REGION" "$FILEPATH"
                STATUS="Region"
            fi
        else
            echo "No region selected"
            exit 1
        fi
        break
        ;;
    "❌ Cancel"| "")
        echo "Cancelled"
        exit 0
        ;;
    *)
        exit 0
        ;;
esac
done

# Check if file was created successfully
if [ -f "$FILEPATH" ]; then
    # For screenshots, copy to clipboard
    wl-copy < "$FILEPATH"
    CLIPBOARD_MSG=" (copied to clipboard)"
    
    # Show notification
    if command -v notify-send &> /dev/null; then
        notify-send "$(echo $STATUS | sed 's/recording/Recording/')" "$STATUS saved to $FILENAME$CLIPBOARD_MSG" -i "$FILEPATH"
    fi
    
    echo "$STATUS saved: $FILEPATH"
else
    echo "Failed to create file"
    exit 1
fi
