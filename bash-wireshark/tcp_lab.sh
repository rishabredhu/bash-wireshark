#!/bin/bash

# Exit on any error
set -e

# Define variables
ALICE_URL="http://gaia.cs.umass.edu/wireshark-labs/alice.txt"
UPLOAD_URL="http://gaia.cs.umass.edu/wireshark-labs/TCP-wireshark-file1.html"
ALICE_FILE="alice.txt"
CAPTURE_FILE="tcp_capture.pcapng"

# Function to cleanup on exit
cleanup() {
    echo "Performing cleanup..."
    local pids=$(pgrep -f "tshark.*$CAPTURE_FILE" || true)
    if [ ! -z "$pids" ]; then
        echo "Stopping tshark processes..."
        sudo kill -2 $pids 2>/dev/null || true
    fi
    rm -f "$ALICE_FILE"
    echo "Cleanup completed"
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Check if tshark is installed
if ! command -v tshark &> /dev/null; then
    echo "Error: tshark is not installed. Please install using:"
    echo "brew install wireshark"
    exit 1
fi

echo "Starting Wireshark TCP Lab automation..."

# Ensure clean start
rm -f "$CAPTURE_FILE"

# Step 1: Download Alice in Wonderland text
echo "Downloading Alice in Wonderland..."
curl -o "$ALICE_FILE" "$ALICE_URL"

# Step 2: Start Wireshark capture
echo "Starting packet capture..."
# Use sudo for packet capture with duration limit
sudo tshark -i en0 -w "$CAPTURE_FILE" -f "host gaia.cs.umass.edu" -a duration:15 &
TSHARK_PID=$!

# Wait a moment for capture to start
sleep 3

# Check if tshark is running
if ! ps -p $TSHARK_PID > /dev/null; then
    echo "Error: tshark failed to start capture"
    exit 1
fi

# Step 3: Upload file using curl
echo "Uploading file to server..."
curl -X POST -F "file=@$ALICE_FILE" "$UPLOAD_URL" > /dev/null

# Wait for capture to complete
echo "Waiting for capture to complete..."
wait $TSHARK_PID || true

# Step 5: Change ownership of capture file back to user
if [ -f "$CAPTURE_FILE" ]; then
    sudo chown $(whoami) "$CAPTURE_FILE"
    
    # Step 6: Apply TCP filter and analyze capture
    echo "Analyzing captured packets..."
    tshark -r "$CAPTURE_FILE" -Y "tcp" -T fields \
        -e ip.src -e tcp.srcport -e ip.dst -e tcp.dstport \
        -e tcp.seq -e tcp.ack > analysis.txt

    echo "Lab completion steps:"
    echo "1. Your capture file is saved as: $CAPTURE_FILE"
    echo "2. Open this file in Wireshark GUI for detailed analysis"
    echo "3. Use Statistics -> TCP Stream Graph -> Time-Sequence-Graph(Stevens) for TCP analysis"
    echo "4. Basic TCP flow analysis is saved in: analysis.txt"
else
    echo "Error: Capture file was not created. Please check your permissions and network interface."
    exit 1
fi

echo "Script completed successfully!"