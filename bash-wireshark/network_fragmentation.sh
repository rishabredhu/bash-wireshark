#!/bin/bash

# Script to analyze IP packets for Wireshark Lab assignment
# Note: Requires root privileges to capture packets

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root"
    exit 1
fi

# Create output directory
OUTPUT_DIR="wireshark_ip_lab_output"
mkdir -p "$OUTPUT_DIR"

# Function to capture packets for traceroute
capture_traceroute() {
    local size=$1
    local duration=30
    local output_file="$OUTPUT_DIR/trace_${size}.pcap"
    
    echo "Starting packet capture for size ${size}..."
    # Start packet capture in background
    tcpdump -w "$output_file" -i any 'icmp or udp' &
    TCPDUMP_PID=$!
    
    # Wait a moment for tcpdump to start
    sleep 2
    
    # Run traceroute with specified packet size
    echo "Running traceroute with packet size ${size}..."
    traceroute google.com $size
    
    # Wait for capture to complete
    sleep 5
    kill $TCPDUMP_PID 2>/dev/null
    
    echo "Capture complete for size ${size}"
    return "$output_file"
}

# Function to analyze captured packets
analyze_packets() {
    local pcap_file=$1
    local analysis_file="$OUTPUT_DIR/analysis.txt"
    
    echo "Analyzing packets from ${pcap_file}..."
    echo "=== Analysis for ${pcap_file} ===" >> "$analysis_file"
    
    # Q1: Get source IP address of first ICMP Echo Request
    echo "Q1. Source IP address:" >> "$analysis_file"
    tcpdump -r "$pcap_file" -nn 'icmp[icmptype]==8' 2>/dev/null | head -n 1 | awk '{print $3}' | cut -d. -f1-4 >> "$analysis_file"
    
    # Q2: Protocol number for ICMP
    echo "Q2. IP Protocol Number (ICMP=1):" >> "$analysis_file"
    echo "1" >> "$analysis_file"
    
    # Q3: IP header analysis
    echo "Q3. IP Header Analysis:" >> "$analysis_file"
    tcpdump -r "$pcap_file" -vv 'icmp[icmptype]==8' 2>/dev/null | head -n 1 >> "$analysis_file"
    
    # Q4: Fragmentation analysis
    echo "Q4. Fragmentation Analysis:" >> "$analysis_file"
    tcpdump -r "$pcap_file" -v 'ip[6] & 0x20 != 0 or ip[6] & 0x40 != 0' 2>/dev/null >> "$analysis_file"
    
    # Additional fields for remaining questions
    echo "Detailed packet analysis:" >> "$analysis_file"
    tcpdump -r "$pcap_file" -vvv 2>/dev/null >> "$analysis_file"
}

# Main execution
echo "Starting Wireshark IP Lab analysis..."

# Capture packets for different sizes
capture_traceroute 56
capture_traceroute 2000
capture_traceroute 3500

# Analyze all captured files
for size in 56 2000 3500; do
    analyze_packets "$OUTPUT_DIR/trace_${size}.pcap"
done

echo "Analysis complete. Results saved in $OUTPUT_DIR/analysis.txt"
echo "Please note: Some questions require manual interpretation of the captured data."
echo "Review the analysis.txt file and the original captures for complete answers."