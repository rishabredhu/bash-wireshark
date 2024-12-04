#!/bin/bash

echo "ICMP Wireshark Lab Script"
echo "========================"

# Function to check if Wireshark is installed
check_wireshark() {
    if ! command -v wireshark &> /dev/null; then
        echo "Error: Wireshark is not installed"
        exit 1
    fi
}

# Function to start packet capture
start_capture() {
    echo "Starting Wireshark capture..."
    # Start Wireshark in background
    open -a Wireshark
    sleep 5  # Give Wireshark time to open
}

# Part 1: ICMP Ping Analysis
run_ping_test() {
    echo -e "\nPart 1: Running Ping Test"
    echo "-------------------------"
    echo "Running 10 pings to www.ust.hk..."
    ping -c 10 www.ust.hk
    echo -e "\nPing test completed."
    echo "Please stop the Wireshark capture and apply filter: icmp"
    read -p "Press Enter when ready to continue..."
}

# Part 2: Traceroute Analysis
run_traceroute_test() {
    echo -e "\nPart 2: Running Traceroute Test"
    echo "-------------------------------"
    echo "Running traceroute to www.inria.fr..."
    traceroute www.inria.fr
    echo -e "\nTraceroute test completed."
    echo "Please stop the Wireshark capture and apply filter: icmp"
    read -p "Press Enter when ready to continue..."
}

# Main script
main() {
    # Check prerequisites
    check_wireshark

    # Part 1: Ping Analysis
    echo "Preparing for Ping analysis..."
    read -p "Press Enter to start Part 1 (Ping Test)..."
    start_capture
    run_ping_test

    # Part 2: Traceroute Analysis
    echo "Preparing for Traceroute analysis..."
    read -p "Press Enter to start Part 2 (Traceroute Test)..."
    start_capture
    run_traceroute_test

    echo -e "\nLab complete!"
    echo "Please save your Wireshark captures for analysis."
}

# Run the script
main
