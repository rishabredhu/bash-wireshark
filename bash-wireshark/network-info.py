import socket
import psutil
import colorama
from colorama import Fore, Style
import sys

def get_local_ip():
    """Get the local IP address of the machine"""
    try:
        # Create a socket to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))  # Connect to Google's DNS
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception:
        return "Unable to determine IP"

def get_active_connections():
    """Get list of active TCP connections"""
    connections = psutil.net_connections(kind='tcp')
    return [conn for conn in connections if conn.status == 'ESTABLISHED']

def format_port_info(port):
    """Format port information with protocol if known"""
    well_known_ports = {
        80: "HTTP",
        443: "HTTPS",
        22: "SSH",
        21: "FTP",
        25: "SMTP",
        53: "DNS"
    }
    return f"{port} ({well_known_ports.get(port, 'Unknown')})"

def display_network_info():
    """Display formatted network information"""
    # Initialize colorama
    colorama.init()

    print(f"\n{Fore.CYAN}=== Network Information ==={Style.RESET_ALL}\n")

    # 1. Client Information
    print(f"{Fore.GREEN}1. Client (Source) Information:{Style.RESET_ALL}")
    local_ip = get_local_ip()
    print(f"   • IP Address: {Fore.YELLOW}{local_ip}{Style.RESET_ALL}")
    
    # Get active connections to show an example port
    connections = get_active_connections()
    if connections:
        example_port = connections[0].laddr.port
        print(f"   • TCP Port: {Fore.YELLOW}{example_port}{Style.RESET_ALL}")
    else:
        print(f"   • TCP Port: {Fore.YELLOW}No active connections{Style.RESET_ALL}")

    # 2. Server Information
    print(f"\n{Fore.GREEN}2. Server Information:{Style.RESET_ALL}")
    try:
        server_ip = socket.gethostbyname("gaia.cs.umass.edu")
        print(f"   • Server IP: {Fore.YELLOW}{server_ip}{Style.RESET_ALL}")
        print(f"   • Server Port: {Fore.YELLOW}{format_port_info(80)}{Style.RESET_ALL}")
    except socket.gaierror:
        print(f"   • {Fore.RED}Unable to resolve server hostname{Style.RESET_ALL}")

    # 3. Client Computer Details
    print(f"\n{Fore.GREEN}3. Client Computer Details:{Style.RESET_ALL}")
    print(f"   • IP Address: {Fore.YELLOW}{local_ip}{Style.RESET_ALL}")
    if connections:
        print(f"   • TCP Port: {Fore.YELLOW}{example_port}{Style.RESET_ALL}")
    else:
        print(f"   • TCP Port: {Fore.YELLOW}No active connections{Style.RESET_ALL}")

if __name__ == "__main__":
    try:
        display_network_info()
    except KeyboardInterrupt:
        print("\nProgram terminated by user")
        sys.exit(0)
    except Exception as e:
        print(f"\n{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")
        sys.exit(1)