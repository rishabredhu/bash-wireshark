#!/bin/bash

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "Error: $1 is not installed. Please install it first."
        exit 1
    fi
}

# Function to cleanup background processes
cleanup() {
    echo "Cleaning up background processes..."
    if [ ! -z "$TCPDUMP_PID" ]; then
        sudo kill -9 $TCPDUMP_PID 2>/dev/null
    fi
    exit
}

# Set trap for cleanup
trap cleanup SIGINT SIGTERM EXIT

# Check for required commands
check_command tcpdump
check_command ping

# Create output directory
OUTPUT_DIR="icmp_lab_output"
mkdir -p $OUTPUT_DIR

# Target hosts
PING_TARGET="www.ust.hk"    # Hong Kong University
TRACERT_TARGET="www.inria.fr" # INRIA in France

echo "Starting ICMP Lab data collection..."

# Part 1: PING capture
echo "Starting ping capture to $PING_TARGET..."
sudo tcpdump -i any -w "$OUTPUT_DIR/ping_capture.pcap" icmp 2>/dev/null & 
TCPDUMP_PID=$!
sleep 2  # Give tcpdump time to start

# Run ping 10 times
echo "Running ping test..."
ping -c 10 $PING_TARGET | tee "$OUTPUT_DIR/ping_output.txt"
sleep 1

# Explicitly kill tcpdump for ping
sudo kill -9 $TCPDUMP_PID 2>/dev/null
unset TCPDUMP_PID
sleep 1

# Part 2: Traceroute capture
echo -e "\nStarting traceroute capture to $TRACERT_TARGET..."
sudo tcpdump -i any -w "$OUTPUT_DIR/tracert_capture.pcap" icmp 2>/dev/null &
TCPDUMP_PID=$!
sleep 2

# Run traceroute
echo "Running traceroute test..."
traceroute $TRACERT_TARGET | tee "$OUTPUT_DIR/tracert_output.txt"
sleep 1

# Kill tcpdump for traceroute
sudo kill -9 $TCPDUMP_PID 2>/dev/null
unset TCPDUMP_PID
sleep 1

# Get system information
echo -e "\nGathering system information..."
ifconfig | grep "inet " | tee "$OUTPUT_DIR/ip_info.txt"

# Create analysis file
echo "Generating analysis file..."
{
    echo "ICMP Lab Analysis Report"
    echo "========================"
    echo "Generated on: $(date)"
    echo
    
    echo "1. IP Address Information"
    echo "------------------------"
    echo "Local Host IP Addresses:"
    ifconfig | grep "inet " | sed 's/^/- /'
    echo
    echo "Destination Hosts:"
    echo "- Ping Target: $PING_TARGET ($(dig +short $PING_TARGET | head -n1))"
    echo "- Traceroute Target: $TRACERT_TARGET ($(dig +short $TRACERT_TARGET | head -n1))"
    echo
    
    echo "2. Ping Analysis"
    echo "---------------"
    echo "Ping Statistics:"
    grep "statistics" -A 2 "$OUTPUT_DIR/ping_output.txt"
    echo
    
    echo "3. Traceroute Analysis"
    echo "---------------------"
    echo "Number of hops: $(grep -c "^[0-9]" "$OUTPUT_DIR/tracert_output.txt")"
    echo
    echo "Path analysis:"
    cat "$OUTPUT_DIR/tracert_output.txt"
    echo
    
    echo "4. ICMP Packet Information"
    echo "-------------------------"
    echo "Ping ICMP Types:"
    echo "- Echo Request (Type 8, Code 0): Used in outgoing ping packets"
    echo "- Echo Reply (Type 0, Code 0): Used in incoming ping responses"
    echo
    echo "Traceroute ICMP Types:"
    echo "- Time Exceeded (Type 11, Code 0): Returned by intermediate routers"
    echo "- Port Unreachable (Type 3, Code 3): Returned by final destination"
    echo
    
    echo "5. Lab Question References"
    echo "-------------------------"
    echo "For Question 1-4: Check ping_capture.pcap in Wireshark"
    echo "For Question 5-10: Check tracert_capture.pcap in Wireshark"
    echo
    echo "Note: Wireshark filter for ICMP packets: icmp"
    
} > "$OUTPUT_DIR/analysis.txt"

echo -e "\nData collection and analysis complete. Files saved in $OUTPUT_DIR:"
ls -l "$OUTPUT_DIR"

echo -e "\nTo view the analysis:"
echo "cat $OUTPUT_DIR/analysis.txt"
echo -e "\nTo analyze the captures:"
echo "wireshark $OUTPUT_DIR/ping_capture.pcap"
echo "wireshark $OUTPUT_DIR/tracert_capture.pcap"