#!/usr/bin/env bash
CACHE_DIR="/tmp/gns3/pcap"
TIMEOUT=15
mkdir -p "$CACHE_DIR"

URL="$1"
HOST_PORT=$(echo "$URL" | sed -E 's/^gns3\+pcap:\/\///' | cut -d? -f1)
HOST=$(echo "$HOST_PORT" | cut -d: -f1)
PORT=$(echo "$HOST_PORT" | cut -d: -f2)
PROTOCOL=$(echo "$URL" | grep -oE 'protocol=[^&]+' | cut -d= -f2)
PROJECT_ID=$(echo "$URL" | grep -oE 'project_id=[^&]+' | cut -d= -f2)
LINK_ID=$(echo "$URL" | grep -oE 'link_id=[^&]+' | cut -d= -f2)
NAME=$(echo "$URL" | grep -oE 'name=[^&]+' | cut -d= -f2 | sed 's/%20/ /g')

# Default values
PROTOCOL=''${PROTOCOL:-https}
API_VERSION="v2"
STREAM_URL="$PROTOCOL://$HOST:$PORT/$API_VERSION/projects/$PROJECT_ID/links/$LINK_ID/pcap"

# Validate required parameters
if [[ -z "$PROJECT_ID" || -z "$LINK_ID" ]]; then
    echo "Error: Missing project_id or link_id" >&2
    read 
    exit 1
fi

# set the title
printf "\033]0;%s\a" "PCAP: $NAME" 

CHECK=`curl -s -o /dev/null -w "%{http_code}" $PROTOCOL://$HOST:$PORT/$API_VERSION/version`
if [[ "$CHECK" == "401" ]]; then
    read -p "Username: " USER
    read -p "Password: " PASSWORD
    echo
    WGET_AUTH="--user=$USER --password=$PASSWORD"
fi

# Create temporary file
TMP_FILE="$CACHE_DIR/pcap-$(date +%s).pcap.fifo"
mkfifo $TMP_FILE

wget $WGET_AUTH --quiet -O "$TMP_FILE" $STREAM_URL&
WGETPID="$!"
trap 'kill $WGETPID 2>/dev/null; rm -f "$TMP_FILE"' EXIT

# Launch termshark
termshark -r "$TMP_FILE" 2>/dev/null

exit 0
