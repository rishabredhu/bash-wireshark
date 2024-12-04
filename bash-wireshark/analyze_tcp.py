#!/usr/bin/env python3
import pyshark
import datetime
import os
import sys

def analyze_tcp_capture(capture_file):
    # Check if file exists
    if not os.path.exists(capture_file):
        print(f"Error: Capture file '{capture_file}' not found.")
        sys.exit(1)

    try:
        # Open the capture file
        print(f"Opening capture file: {capture_file}")
        cap = pyshark.FileCapture(capture_file, display_filter='tcp')
        packets = list(cap)  # Load all packets into memory
        
        if not packets:
            print("Error: No TCP packets found in capture file.")
            sys.exit(1)

        print(f"Found {len(packets)} TCP packets")

        with open('tcp_lab_answers.txt', 'w') as f:
            f.write("TCP Wireshark Lab Analysis\n")
            f.write("=========================\n\n")

            # Find SYN packet
            syn_packet = None
            for packet in packets:
                try:
                    if hasattr(packet.tcp, 'flags') and packet.tcp.flags == '0x00000002':  # SYN flag
                        syn_packet = packet
                        break
                except AttributeError:
                    continue

            # Questions 1 & 2: Client and Server Information
            f.write("1 & 2. Connection Information:\n")
            if syn_packet:
                f.write("Initial SYN packet found:\n")
                f.write(f"   Client IP: {syn_packet.ip.src}\n")
                f.write(f"   Client Port: {syn_packet.tcp.srcport}\n")
                f.write(f"   Server IP: {syn_packet.ip.dst}\n")
                f.write(f"   Server Port: {syn_packet.tcp.dstport}\n")
            else:
                # Get information from first packet instead
                first_packet = packets[0]
                f.write("No SYN packet found, using first packet in capture:\n")
                f.write(f"   Source IP: {first_packet.ip.src}\n")
                f.write(f"   Source Port: {first_packet.tcp.srcport}\n")
                f.write(f"   Destination IP: {first_packet.ip.dst}\n")
                f.write(f"   Destination Port: {first_packet.tcp.dstport}\n")
            f.write("\n")

            # Question 4: TCP SYN details
            f.write("4. TCP SYN Details:\n")
            if syn_packet:
                f.write(f"   Sequence number: {syn_packet.tcp.seq}\n")
                f.write("   Identified as SYN by flags field with SYN bit set (0x02)\n")
            else:
                f.write("   No SYN packet found in capture\n")
            f.write("\n")

            # Question 5: Find SYNACK
            synack_packet = None
            for packet in packets:
                try:
                    if hasattr(packet.tcp, 'flags') and packet.tcp.flags == '0x00000012':  # SYN+ACK flags
                        synack_packet = packet
                        break
                except AttributeError:
                    continue

            f.write("5. TCP SYNACK Details:\n")
            if synack_packet:
                f.write(f"   Sequence number: {synack_packet.tcp.seq}\n")
                f.write(f"   Acknowledgment number: {synack_packet.tcp.ack}\n")
                f.write("   Identified as SYNACK by flags field with SYN and ACK bits set (0x12)\n")
            else:
                f.write("   No SYNACK packet found in capture\n")
            f.write("\n")

            # Question 6: Find HTTP POST
            post_packet = None
            for packet in packets:
                try:
                    if 'POST' in str(packet):
                        post_packet = packet
                        break
                except:
                    continue

            f.write("6. HTTP POST Details:\n")
            if post_packet:
                f.write(f"   Sequence number: {post_packet.tcp.seq}\n")
            else:
                f.write("   No HTTP POST packet found in capture\n")
            f.write("\n")

            # Find data segments
            data_segments = []
            for packet in packets:
                try:
                    if hasattr(packet.tcp, 'len') and int(packet.tcp.len) > 0:
                        data_segments.append({
                            'seq': packet.tcp.seq,
                            'time': float(packet.sniff_timestamp),
                            'length': int(packet.tcp.len),
                            'window': int(packet.tcp.window_size)
                        })
                except AttributeError:
                    continue

            # Question 7-8: Analyze first six data segments
            f.write("7-8. First Six Data Segments:\n")
            for i, seg in enumerate(data_segments[:6]):
                f.write(f"   Segment {i+1}:\n")
                f.write(f"   Sequence number: {seg['seq']}\n")
                f.write(f"   Time: {datetime.datetime.fromtimestamp(seg['time']).strftime('%H:%M:%S.%f')}\n")
                f.write(f"   Length: {seg['length']} bytes\n")
                f.write("\n")

            # Question 9: Window size analysis
            window_sizes = [seg['window'] for seg in data_segments]
            if window_sizes:
                f.write("9. Window Size Analysis:\n")
                f.write(f"   Minimum window size: {min(window_sizes)} bytes\n")
                f.write(f"   Maximum window size: {max(window_sizes)} bytes\n")
                f.write(f"   Average window size: {sum(window_sizes)/len(window_sizes):.2f} bytes\n")
            f.write("\n")

            # Question 10-12: Additional analysis
            f.write("10. Retransmission Analysis:\n")
            seq_numbers = [seg['seq'] for seg in data_segments]
            duplicates = len(seq_numbers) - len(set(seq_numbers))
            f.write(f"   Found {duplicates} potential retransmissions\n\n")

            if data_segments:
                total_time = data_segments[-1]['time'] - data_segments[0]['time']
                total_bytes = sum(seg['length'] for seg in data_segments)
                throughput = total_bytes / total_time if total_time > 0 else 0
                
                f.write("12. Throughput Analysis:\n")
                f.write(f"   Total bytes transferred: {total_bytes}\n")
                f.write(f"   Total time: {total_time:.2f} seconds\n")
                f.write(f"   Throughput: {throughput:.2f} bytes/second\n")

            print("Analysis complete. Results written to tcp_lab_answers.txt")

    except Exception as e:
        print(f"Error analyzing capture file: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    analyze_tcp_capture("tcp_capture.pcapng")