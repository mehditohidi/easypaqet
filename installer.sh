#!/bin/bash
set -e

# ========== UI FUNCTIONS ==========
#!/bin/bash

# Clear the screen
clear

# Logo lines in an array
logo=(
" ╔════════════════════════════════════════════════╗"
" ║                                                ║"
" ║   ███████╗ █████╗ ███████╗██╗   ██╗            ║"
" ║   ██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝            ║"
" ║   █████╗  ███████║███████╗ ╚████╔╝             ║"
" ║   ██╔══╝  ██╔══██║╚════██║  ╚██╔╝              ║"
" ║   ███████╗██║  ██║███████║   ██║               ║"
" ║   ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝               ║"
" ║                                                ║"
" ║   ██████╗  █████╗  ██████╗ ███████╗████████╗   ║"
" ║   ██╔══██╗██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝   ║"
" ║   ██████╔╝███████║██║   ██║█████╗     ██║      ║"
" ║   ██╔═══╝ ██╔══██║██║▄▄ ██║██╔══╝     ██║      ║"
" ║   ██║     ██║  ██║╚██████╔╝███████╗   ██║      ║"
" ║   ╚═╝     ╚═╝  ╚═╝ ╚══▀▀═╝ ╚══════╝   ╚═╝      ║"
" ║                                                ║"
" ║                                                ║"
" ║           by github.com/mehditohidi            ║"
" ║                                                ║"
" ╚════════════════════════════════════════════════╝"
)

# Rainbow colors (magenta, cyan, red, yellow, green)
colors=(35 36 31 33 32)

# Animate letter by letter
for line in "${logo[@]}"; do
    for ((i=0; i<${#line}; i++)); do
        # Pick a random color for each character
        color=${colors[$RANDOM % ${#colors[@]}]}
        echo -ne "\e[1;${color}m${line:$i:1}\e[0m"
        sleep 0.002  # 2ms delay between letters
    done
    echo ""  # New line after each logo line
done

# Reset color at the end
echo -e "\e[0m"



print_header() {
    echo -e "\n\e[1;35m══════════════════════════════════════════════════════════\e[0m"
    echo -e "\e[1;35m   $1\e[0m"
    echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"
}

print_step() {
    echo -e "\e[1;34m[→]\e[0m $1"
}

print_success() {
    echo -e "\e[1;32m[✓]\e[0m $1"
}

print_warning() {
    echo -e "\e[1;33m[!]\e[0m $1"
}

print_error() {
    echo -e "\e[1;31m[✗]\e[0m $1"
}

# ========== MAIN MENU ==========
print_header "MAIN CONFIGURATION"
echo ""
echo -e "\e[1;36m   1) Install as SERVER\e[0m"
echo -e "\e[1;36m   2) Install as CLIENT\e[0m"
echo -e "\e[1;36m   3) See Paqet STATUS\e[0m"
echo -e "\e[1;36m   4) See Paqet Logs\e[0m"
echo -e "\e[1;36m   5) Test Connection (Client Only)\e[0m"
echo -e "\e[1;36m   6) Uninstall\e[0m"
echo -e "\e[1;36m   7) Exit\e[0m"
echo ""
echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"

while true; do
    read -p "Choose option (1 - 7): " MODE
    case $MODE in
        1|2|3|4|5|6|7) break ;;
        *) print_error "Invalid option. Please enter 1 to 7." ;;
    esac
done

# ========== HANDLE NON-INSTALLATION OPTIONS ==========
case $MODE in
    3) # See Paqet STATUS
        clear
        print_header "PAQET SERVICE STATUS"
        if systemctl is-active paqet >/dev/null 2>&1; then
            echo -e "\e[1;32m✓ Paqet service is RUNNING\e[0m"
            echo ""
            systemctl status paqet --no-pager -l
        else
            echo -e "\e[1;31m✗ Paqet service is NOT RUNNING\e[0m"
            echo ""
            echo "Possible reasons:"
            echo "1. Paqet is not installed"
            echo "2. Service is stopped"
            echo "3. Installation failed"
            echo ""
            echo "Check if installed: ls /etc/paqet/"
            echo "Check logs: journalctl -u paqet -n 50"
        fi
        exit 0
        ;;
        
    4) # See Paqet Logs
        clear
        print_header "PAQET SERVICE LOGS"
        if systemctl is-active paqet >/dev/null 2>&1; then
            echo -e "\e[1;32mShowing recent logs (last 50 lines):\e[0m"
            echo ""
            journalctl -u paqet -n 50 --no-pager
            echo ""
            echo -e "\e[1;36mPress Ctrl+C to stop following logs\e[0m"
            read -p "Follow logs in real-time? (y/N): " FOLLOW_LOGS
            if [[ "$FOLLOW_LOGS" =~ ^[Yy]$ ]]; then
                journalctl -u paqet -f
            fi
        else
            echo -e "\e[1;33mService not running. Showing last 100 lines of journal:\e[0m"
            echo ""
            journalctl -u paqet -n 100 --no-pager
        fi
        exit 0
        ;;
        
    5) # Test Connection
        clear
        print_header "TEST CONNECTION"
        
        # Check if SOCKS5 is configured
        if [[ -f "/etc/paqet/client.yaml" ]]; then
            SOCKS_PORT=$(grep -A1 "socks5:" /etc/paqet/client.yaml | grep "listen:" | cut -d: -f3 | tr -d ' ' | cut -d'"' -f1 2>/dev/null || echo "1080")
            SOCKS_HOST=$(grep -A1 "socks5:" /etc/paqet/client.yaml | grep "listen:" | cut -d: -f2 | tr -d ' ' | cut -d'"' -f1 2>/dev/null || echo "127.0.0.1")
            
            echo -e "\e[1;37mTesting SOCKS5 proxy at: \e[1;33m${SOCKS_HOST}:${SOCKS_PORT}\e[0m"
            echo ""
            
            # Test 1: Check if service is running
            if ! systemctl is-active paqet >/dev/null 2>&1; then
                print_error "Paqet service is not running!"
                echo "Start it with: systemctl start paqet"
                exit 1
            fi
            
            # Test 2: Test connection with curl
            print_step "Testing connection to httpbin.org..."
            if command -v curl >/dev/null 2>&1; then
                TIMEOUT=10
                RESPONSE=$(timeout $TIMEOUT curl -s --proxy "socks5h://${SOCKS_HOST}:${SOCKS_PORT}" https://httpbin.org/ip 2>/dev/null || echo "FAILED")
                
                if [[ "$RESPONSE" == "FAILED" ]] || [[ -z "$RESPONSE" ]]; then
                    print_error "Connection test FAILED"
                    echo "Possible issues:"
                    echo "1. Server is down or unreachable"
                    echo "2. Firewall blocking connection"
                    echo "3. Wrong server IP/port in config"
                    echo "4. Incorrect secret key"
                    echo ""
                    echo "Check logs: journalctl -u paqet -n 20"
                else
                    print_success "Connection test PASSED"
                    echo "Response from httpbin.org:"
                    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
                fi
            else
                print_warning "curl not installed. Installing..."
                apt-get update >/dev/null 2>&1 && apt-get install -y curl >/dev/null 2>&1
                print_step "Retrying connection test..."
                RESPONSE=$(timeout 10 curl -s --proxy "socks5h://${SOCKS_HOST}:${SOCKS_PORT}" https://httpbin.org/ip 2>/dev/null || echo "FAILED")
                
                if [[ "$RESPONSE" == "FAILED" ]] || [[ -z "$RESPONSE" ]]; then
                    print_error "Connection test FAILED"
                else
                    print_success "Connection test PASSED"
                    echo "Response:"
                    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
                fi
            fi
            
            # Test 3: Check local proxy
            echo ""
            print_step "Testing local proxy accessibility..."
            if nc -z "$SOCKS_HOST" "$SOCKS_PORT" 2>/dev/null; then
                print_success "Local proxy is listening on ${SOCKS_HOST}:${SOCKS_PORT}"
            else
                print_warning "Local proxy is NOT listening"
                echo "Check if SOCKS5 is enabled in /etc/paqet/client.yaml"
            fi
            
        else
            print_error "Client configuration not found at /etc/paqet/client.yaml"
            echo "Make sure you installed as a CLIENT first."
        fi
        exit 0
        ;;
        
    6) # Uninstall
        clear
        print_header "PAQET UNINSTALLER"
        
        echo -e "\e[1;31m⚠️  WARNING: This will completely remove Paqet from your system!\e[0m"
        echo ""
        read -p "Are you sure you want to uninstall? (type 'UNINSTALL' to confirm): " CONFIRM_UNINSTALL
        
        if [[ "$CONFIRM_UNINSTALL" != "UNINSTALL" ]]; then
            print_error "Uninstall cancelled."
            exit 0
        fi
        
        print_step "Stopping Paqet service..."
        systemctl stop paqet 2>/dev/null || true
        systemctl disable paqet 2>/dev/null || true
        
        print_step "Removing systemd service..."
        rm -f /etc/systemd/system/paqet.service
        
        print_step "Removing configuration files..."
        rm -rf /etc/paqet 2>/dev/null || true
        
        print_step "Removing binary..."
        rm -f /usr/local/bin/paqet 2>/dev/null || true
        
        print_step "Cleaning iptables rules..."
        # Remove specific paqet rules (more targeted cleanup)
        for PORT in 9999 8888 7777 443 80; do
            iptables -t raw -D PREROUTING -p tcp --dport ${PORT} -j NOTRACK 2>/dev/null || true
            iptables -t raw -D OUTPUT -p tcp --sport ${PORT} -j NOTRACK 2>/dev/null || true
            iptables -t mangle -D OUTPUT -p tcp --sport ${PORT} --tcp-flags RST RST -j DROP 2>/dev/null || true
            iptables -t filter -D INPUT -p tcp --dport ${PORT} -j ACCEPT 2>/dev/null || true
            iptables -t filter -D OUTPUT -p tcp --sport ${PORT} -j ACCEPT 2>/dev/null || true
        done
        
        # Save iptables changes
        if command -v netfilter-persistent >/dev/null 2>&1; then
            netfilter-persistent save 2>/dev/null || true
        elif command -v iptables-save >/dev/null 2>&1; then
            iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
        fi
        
        print_step "Reloading systemd..."
        systemctl daemon-reload
        
        print_success "Paqet has been completely uninstalled!"
        echo ""
        echo "Removed:"
        echo "✓ /usr/local/bin/paqet"
        echo "✓ /etc/paqet/"
        echo "✓ /etc/systemd/system/paqet.service"
        echo "✓ iptables rules"
        echo ""
        echo "You may want to reboot to ensure all network changes take effect."
        exit 0
        ;;
        
    7) # Exit
        clear
        echo -e "\e[1;35m"
        echo "Thank you for using EaSy PaQeT!"
        echo "Goodbye! 👋"
        echo -e "\e[0m"
        exit 0
        ;;
esac

# ========== INSTALLATION LOGIC (for options 1 and 2) ==========
if [[ "$MODE" == "1" ]]; then
    ROLE="SERVER"
    CONFIG_TYPE="server"
else
    ROLE="CLIENT"
    CONFIG_TYPE="client"
fi

print_step "Selected mode: $ROLE"

# ========== BASIC CONFIGURATION ==========
print_header "BASIC SETTINGS"

# Detect network
print_step "Detecting network configuration..."
IFACE=$(ip route | awk '/default/ {print $5}' | head -n1)
ROUTER_IP=$(ip route | awk '/default/ {print $3}' | head -n1)
ROUTER_MAC=$(ip neigh | awk -v ip="$ROUTER_IP" '$1==ip {print $5}' | head -n1)
PUBLIC_IP=$(curl -s --max-time 5 https://api.ipify.org || echo "unknown")

echo -e "\e[1;37mDetected Interface: \e[1;33m$IFACE\e[0m"
echo -e "\e[1;37mDetected Gateway MAC: \e[1;33m$ROUTER_MAC\e[0m"
echo -e "\e[1;37mPublic IP: \e[1;33m$PUBLIC_IP\e[0m"

# Port configuration with warning
while true; do
    read -p "Enter port (default 9999): " PORT
    PORT=${PORT:-9999}
    
    if [[ "$PORT" -lt 1024 ]]; then
        print_warning "Ports below 1024 require root privileges."
        read -p "Continue? (y/N): " CONFIRM_LOWPORT
        [[ "$CONFIRM_LOWPORT" =~ ^[Yy]$ ]] && break
    elif [[ "$PORT" == "80" || "$PORT" == "443" || "$PORT" == "22" || "$PORT" == "53" ]]; then
        print_warning "Using standard port $PORT is NOT RECOMMENDED!"
        echo "   iptables rules may interfere with system services."
        read -p "Use a different port? (Y/n): " CHANGE_PORT
        if [[ ! "$CHANGE_PORT" =~ ^[Nn]$ ]]; then
            continue
        else
            break
        fi
    else
        break
    fi
done

# Log level
echo ""
echo -e "\e[1;37mLog levels: \e[0mnone, debug, info, warn, error, fatal"
read -p "Log level (default: info): " LOG_LEVEL
LOG_LEVEL=${LOG_LEVEL:-info}

# ========== TRANSPORT CONFIGURATION ==========
print_header "TRANSPORT PROTOCOL"

# Connection count
while true; do
    read -p "Number of connections (1-256, default: 1): " CONN_COUNT
    CONN_COUNT=${CONN_COUNT:-1}
    if [[ "$CONN_COUNT" =~ ^[0-9]+$ ]] && [ "$CONN_COUNT" -ge 1 ] && [ "$CONN_COUNT" -le 256 ]; then
        break
    else
        print_error "Please enter a number between 1 and 256"
    fi
done

# KCP mode
echo ""
echo -e "\e[1;37mKCP Modes:\e[0m"
echo "  normal  - Conservative, TCP-like behavior"
echo "  fast    - Balanced speed and reliability (default)"
echo "  fast2   - More aggressive"
echo "  fast3   - Most aggressive, lowest latency"
echo "  manual  - Custom parameters"
read -p "KCP mode (default: fast): " KCP_MODE
KCP_MODE=${KCP_MODE:-fast}

# Manual KCP parameters
if [[ "$KCP_MODE" == "manual" ]]; then
    print_header "MANUAL KCP PARAMETERS"
    
    read -p "Nodelay (0=disable, 1=enable, default: 1): " KCP_NODELAY
    KCP_NODELAY=${KCP_NODELAY:-1}
    
    while true; do
        read -p "Interval in ms (10-5000, default: 10): " KCP_INTERVAL
        KCP_INTERVAL=${KCP_INTERVAL:-10}
        if [[ "$KCP_INTERVAL" =~ ^[0-9]+$ ]] && [ "$KCP_INTERVAL" -ge 10 ] && [ "$KCP_INTERVAL" -le 5000 ]; then
            break
        else
            print_error "Please enter a number between 10 and 5000"
        fi
    done
    
    read -p "Resend (0-2, default: 2): " KCP_RESEND
    KCP_RESEND=${KCP_RESEND:-2}
    
    read -p "No congestion control (0=enabled, 1=disabled, default: 1): " KCP_NOCONGESTION
    KCP_NOCONGESTION=${KCP_NOCONGESTION:-1}
    
    read -p "Write delay (false=flush immediately, true=batch, default: false): " KCP_WDELAY
    KCP_WDELAY=${KCP_WDELAY:-false}
    
    read -p "ACK no delay (true=immediate ACKs, false=batch, default: true): " KCP_ACKNODELAY
    KCP_ACKNODELAY=${KCP_ACKNODELAY:-true}
    
    while true; do
        read -p "MTU (50-1500, default: 1350): " KCP_MTU
        KCP_MTU=${KCP_MTU:-1350}
        if [[ "$KCP_MTU" =~ ^[0-9]+$ ]] && [ "$KCP_MTU" -ge 50 ] && [ "$KCP_MTU" -le 1500 ]; then
            break
        else
            print_error "Please enter a number between 50 and 1500"
        fi
    done
    
    # Window sizes
    if [[ "$MODE" == "1" ]]; then
        read -p "Receive window size (default: 1024): " KCP_RCVWND
        KCP_RCVWND=${KCP_RCVWND:-1024}
        read -p "Send window size (default: 1024): " KCP_SNDWND
        KCP_SNDWND=${KCP_SNDWND:-1024}
    else
        read -p "Receive window size (default: 512): " KCP_RCVWND
        KCP_RCVWND=${KCP_RCVWND:-512}
        read -p "Send window size (default: 512): " KCP_SNDWND
        KCP_SNDWND=${KCP_SNDWND:-512}
    fi
fi

# ========== ENCRYPTION CONFIGURATION ==========
print_header "ENCRYPTION SETTINGS"

echo -e "\e[1;37mAvailable encryption algorithms:\e[0m"
echo "  aes, aes-128, aes-128-gcm, aes-192, aes-256"
echo "  salsa20, chacha20, blowfish, twofish, cast5"
echo "  3des, tea, xtea, sm4, xor"
echo "  none - Plaintext with header"
echo "  null - Raw data (no encryption)"

read -p "Encryption algorithm (default: aes): " ENCRYPTION_ALGO
ENCRYPTION_ALGO=${ENCRYPTION_ALGO:-aes}

# Security warnings
case $ENCRYPTION_ALGO in
    none)
        print_warning "'none' mode provides NO ENCRYPTION!"
        echo "   Data is transmitted in plaintext with protocol headers."
        read -p "Are you sure? (type YES to continue): " CONFIRM_NONE
        if [[ "$CONFIRM_NONE" != "YES" ]]; then
            ENCRYPTION_ALGO="aes"
            print_success "Changed to default encryption (aes)"
        fi
        ;;
    null)
        print_warning "'null' mode provides NO ENCRYPTION and NO HEADERS!"
        echo "   This is the least secure and most detectable mode."
        read -p "Are you sure? (type YES to continue): " CONFIRM_NULL
        if [[ "$CONFIRM_NULL" != "YES" ]]; then
            ENCRYPTION_ALGO="aes"
            print_success "Changed to default encryption (aes)"
        fi
        ;;
esac

# Generate or get secret
if [[ "$MODE" == "1" ]]; then
    print_step "Will generate encryption key after installation..."
    SECRET=""  # Will be generated later
else
    while true; do
        read -p "Enter SERVER SECRET key: " SECRET
        if [[ -z "$SECRET" ]]; then
            print_error "Secret key cannot be empty"
        elif [[ ${#SECRET} -lt 16 ]]; then
            print_warning "Secret key should be at least 16 characters"
            read -p "Continue anyway? (y/N): " SHORT_SECRET
            [[ "$SHORT_SECRET" =~ ^[Yy]$ ]] && break
        else
            break
        fi
    done
fi

# ========== NETWORK CONFIGURATION ==========
print_header "NETWORK SETTINGS"

# TCP Flags
echo ""
echo -e "\e[1;37mTCP Flag Configuration:\e[0m"
echo "  Common flags: PA (Push+Ack), S (Syn), A (Ack), SA (Syn+Ack)"
echo "  Use comma to cycle multiple flags: PA,S,A"

read -p "Local TCP flags (default: PA): " LOCAL_FLAGS
LOCAL_FLAGS=${LOCAL_FLAGS:-PA}

# Convert to YAML array format
if [[ "$LOCAL_FLAGS" == *","* ]]; then
    IFS=',' read -ra FLAG_ARRAY <<< "$LOCAL_FLAGS"
    LOCAL_FLAGS_YAML="["
    for flag in "${FLAG_ARRAY[@]}"; do
        LOCAL_FLAGS_YAML="$LOCAL_FLAGS_YAML\"$(echo $flag | xargs)\", "
    done
    LOCAL_FLAGS_YAML="${LOCAL_FLAGS_YAML%, }]"
else
    LOCAL_FLAGS_YAML="[\"$LOCAL_FLAGS\"]"
fi

if [[ "$MODE" == "2" ]]; then
    read -p "Remote TCP flags (default: PA): " REMOTE_FLAGS
    REMOTE_FLAGS=${REMOTE_FLAGS:-PA}
    
    if [[ "$REMOTE_FLAGS" == *","* ]]; then
        IFS=',' read -ra FLAG_ARRAY <<< "$REMOTE_FLAGS"
        REMOTE_FLAGS_YAML="["
        for flag in "${FLAG_ARRAY[@]}"; do
            REMOTE_FLAGS_YAML="$REMOTE_FLAGS_YAML\"$(echo $flag | xargs)\", "
        done
        REMOTE_FLAGS_YAML="${REMOTE_FLAGS_YAML%, }]"
    else
        REMOTE_FLAGS_YAML="[\"$REMOTE_FLAGS\"]"
    fi
fi

# PCAP Buffer
echo ""
read -p "Configure custom PCAP buffer? (y/N): " CUSTOM_PCAP
if [[ "$CUSTOM_PCAP" =~ ^[Yy]$ ]]; then
    if [[ "$MODE" == "1" ]]; then
        DEFAULT_PCAP=8388608  # 8MB for server
    else
        DEFAULT_PCAP=4194304  # 4MB for client
    fi
    read -p "PCAP socket buffer in bytes (default: $DEFAULT_PCAP): " PCAP_SOCKBUF
    PCAP_SOCKBUF=${PCAP_SOCKBUF:-$DEFAULT_PCAP}
fi

# IPv6
read -p "Enable IPv6? (y/N): " ENABLE_IPV6
if [[ "$ENABLE_IPV6" =~ ^[Yy]$ ]]; then
    read -p "IPv6 address (with brackets, e.g., [2001:db8::1]): " IPV6_ADDR
    read -p "IPv6 router MAC address: " IPV6_ROUTER_MAC
fi

# ========== CLIENT-SPECIFIC CONFIGURATION ==========
if [[ "$MODE" == "2" ]]; then
    print_header "CLIENT CONFIGURATION"
    
    # Server connection
    while true; do
        read -p "Enter SERVER IP address: " SERVER_IP
        if [[ -z "$SERVER_IP" ]]; then
            print_error "Server IP cannot be empty"
        else
            break
        fi
    done
    
    # read -p "Enter SERVER PORT (default $PORT): " SERVER_PORT
    # SERVER_PORT=${SERVER_PORT:-$PORT}

    SERVER_PORT=$PORT
    
    # SOCKS5 Proxy
    echo ""
    read -p "Enable SOCKS5 proxy? (Y/n): " ENABLE_SOCKS5
    ENABLE_SOCKS5=${ENABLE_SOCKS5:-Y}
    
    if [[ "$ENABLE_SOCKS5" =~ ^[Yy]$ ]]; then
        read -p "SOCKS5 listen address (default: 127.0.0.1): " SOCKS_LISTEN
        SOCKS_LISTEN=${SOCKS_LISTEN:-127.0.0.1}
        
        read -p "SOCKS5 port (default: 1080): " SOCKS_PORT
        SOCKS_PORT=${SOCKS_PORT:-1080}
        
        read -p "Enable SOCKS5 authentication? (y/N): " SOCKS_AUTH
        if [[ "$SOCKS_AUTH" =~ ^[Yy]$ ]]; then
            read -p "SOCKS5 username: " SOCKS_USER
            read -p "SOCKS5 password: " SOCKS_PASSWORD
        fi
    fi
    
    # Port Forwarding
    echo ""
    read -p "Configure port forwarding? (y/N): " ENABLE_FORWARDING
    if [[ "$ENABLE_FORWARDING" =~ ^[Yy]$ ]]; then
        FORWARD_RULES=""
        FORWARD_COUNT=0
        
        while true; do
            FORWARD_COUNT=$((FORWARD_COUNT + 1))
            echo ""
            echo "Port Forwarding Rule #$FORWARD_COUNT:"
            read -p "  Local listen (e.g., 127.0.0.1:8080): " FWD_LOCAL
            read -p "  Target address (via server, e.g., 192.168.1.100:80): " FWD_TARGET
            read -p "  Protocol (tcp/udp, default: tcp): " FWD_PROTOCOL
            FWD_PROTOCOL=${FWD_PROTOCOL:-tcp}
            
            if [[ -z "$FORWARD_RULES" ]]; then
                FORWARD_RULES="  - listen: \"$FWD_LOCAL\"\n    target: \"$FWD_TARGET\"\n    protocol: \"$FWD_PROTOCOL\""
            else
                FORWARD_RULES="$FORWARD_RULES\n  - listen: \"$FWD_LOCAL\"\n    target: \"$FWD_TARGET\"\n    protocol: \"$FWD_PROTOCOL\""
            fi
            
            read -p "Add another forwarding rule? (y/N): " ADD_MORE
            [[ ! "$ADD_MORE" =~ ^[Yy]$ ]] && break
        done
    fi
fi

# ========== FEC CONFIGURATION ==========
print_header "FORWARD ERROR CORRECTION"
read -p "Enable FEC for lossy networks? (y/N): " ENABLE_FEC
if [[ "$ENABLE_FEC" =~ ^[Yy]$ ]]; then
    read -p "Data shards (default: 10): " DSHARD
    DSHARD=${DSHARD:-10}
    
    read -p "Parity shards (default: 3): " PSHARD
    PSHARD=${PSHARD:-3}
fi

# ========== INSTALLATION ==========
print_header "SYSTEM INSTALLATION"

print_step "Selecting fastest Ubuntu mirror..."

set +e

MIRRORS=(
mirror.iranserver.com
ir.ubuntu.sindad.cloud
mirror.arvancloud.ir
archive.ubuntu.petiak.ir
ubuntu.hostiran.ir
mirrors.pardisco.co
ubuntu.pars.host
mirror.0-1.cloud
ubuntu.shatel.ir
mirror.faraso.org
repo.linuxmirrors.ir
)

BEST_MIRROR=""
BEST_TIME=999999

for m in "${MIRRORS[@]}"; do
  echo "Testing $m ..."

  t=$(curl --connect-timeout 2 --max-time 4 \
      -o /dev/null -s -w "%{time_total}" \
      https://$m/ubuntu/ || true)

  if [[ -z "$t" ]]; then
    echo "  ❌ timeout"
    continue
  fi

  printf "  ✅ %.2fs\n" "$t"

  t_ms=${t/./}

  if (( t_ms < BEST_TIME )); then
    BEST_TIME=$t_ms
    BEST_MIRROR=$m
  fi
done

if [[ -n "$BEST_MIRROR" ]]; then
  print_success "Best mirror: $BEST_MIRROR"

  sed -i.bak "s|http://.*archive.ubuntu.com/ubuntu|https://$BEST_MIRROR/ubuntu|g" /etc/apt/sources.list 2>/dev/null || true
  sed -i.bak "s|http://.*security.ubuntu.com/ubuntu|https://$BEST_MIRROR/ubuntu|g" /etc/apt/sources.list 2>/dev/null || true
  sed -i.bak "s|http://.*archive.ubuntu.com/ubuntu|https://$BEST_MIRROR/ubuntu|g" /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true
fi

set -e
echo


# Architecture detection and paqet download
print_step "Detecting architecture and downloading paqet..."
PAQET_VER="v1.0.0-alpha.14"
ARCH=$(uname -m)

case "$ARCH" in
    x86_64) PAQET_FILE="paqet-linux-amd64-${PAQET_VER}.tar.gz" ;;
    aarch64) PAQET_FILE="paqet-linux-arm64-${PAQET_VER}.tar.gz" ;;
    armv7l|armhf) PAQET_FILE="paqet-linux-arm32-${PAQET_VER}.tar.gz" ;;
    *) print_error "Unsupported architecture: $ARCH"; exit 1 ;;
esac

cd /tmp
wget --show-progress -q --progress=bar:force \
https://github.com/hanselime/paqet/releases/download/${PAQET_VER}/${PAQET_FILE}
tar -xzf ${PAQET_FILE} 2>/dev/null

# Find and install the binary
PAQET_BINARY=$(find /tmp -name "paqet_linux_*" -type f | head -n1)
if [[ -z "$PAQET_BINARY" ]]; then
    print_error "Could not find paqet binary in archive"
    exit 1
fi

mv "$PAQET_BINARY" /usr/local/bin/paqet
chmod +x /usr/local/bin/paqet

# Fix libpcap symlink if needed
ln -sf /usr/lib/x86_64-linux-gnu/libpcap.so /usr/lib/x86_64-linux-gnu/libpcap.so.0.8 2>/dev/null || true
ldconfig 2>/dev/null

mkdir -p /etc/paqet
print_success "Paqet installed to /usr/local/bin/paqet"

# Generate secret for server
if [[ "$MODE" == "1" ]]; then
    SECRET=$(paqet secret 2>/dev/null | tail -n1)
    if [[ -z "$SECRET" ]]; then
        print_warning "Could not generate secret with paqet command"
        SECRET=$(openssl rand -hex 32 2>/dev/null || echo "changeme-$(date +%s)")
    fi
fi

# ========== CONFIGURATION FILE GENERATION ==========
print_header "GENERATING CONFIGURATION"

CONFIG_FILE="/etc/paqet/${CONFIG_TYPE}.yaml"

# Common configuration start
cat > "$CONFIG_FILE" << EOF
# paqet ${ROLE} Configuration
# Generated by EaSy PaQeT Installer
# $(date)

role: "${CONFIG_TYPE}"

log:
  level: "${LOG_LEVEL}"
EOF

# Server-specific configuration
if [[ "$MODE" == "1" ]]; then
    cat >> "$CONFIG_FILE" << EOF

listen:
  addr: "0.0.0.0:${PORT}"
EOF
fi

# SOCKS5 configuration for client
if [[ "$MODE" == "2" ]] && [[ "$ENABLE_SOCKS5" =~ ^[Yy]$ ]]; then
    cat >> "$CONFIG_FILE" << EOF

socks5:
  - listen: "${SOCKS_LISTEN}:${SOCKS_PORT}"
EOF
    if [[ "$SOCKS_AUTH" =~ ^[Yy]$ ]]; then
        cat >> "$CONFIG_FILE" << EOF
    username: "${SOCKS_USER}"
    password: "${SOCKS_PASSWORD}"
EOF
    else
        cat >> "$CONFIG_FILE" << EOF
    username: ""
    password: ""
EOF
    fi
fi

# Port forwarding for client
if [[ "$MODE" == "2" ]] && [[ "$ENABLE_FORWARDING" =~ ^[Yy]$ ]]; then
    cat >> "$CONFIG_FILE" << EOF

forward:
$(echo -e "$FORWARD_RULES")
EOF
fi

# Network configuration (common)
cat >> "$CONFIG_FILE" << EOF

network:
  interface: "${IFACE}"
EOF

# IPv4 configuration
if [[ "$MODE" == "1" ]]; then
    cat >> "$CONFIG_FILE" << EOF
  ipv4:
    addr: "${PUBLIC_IP}:${PORT}"
    router_mac: "${ROUTER_MAC}"
EOF
else
    cat >> "$CONFIG_FILE" << EOF
  ipv4:
    addr: "${PUBLIC_IP}:0"
    router_mac: "${ROUTER_MAC}"
EOF
fi

# IPv6 configuration
if [[ "$ENABLE_IPV6" =~ ^[Yy]$ ]]; then
    if [[ "$MODE" == "1" ]]; then
        cat >> "$CONFIG_FILE" << EOF
  ipv6:
    addr: "${IPV6_ADDR}:${PORT}"
    router_mac: "${IPV6_ROUTER_MAC}"
EOF
    else
        cat >> "$CONFIG_FILE" << EOF
  ipv6:
    addr: "${IPV6_ADDR}:0"
    router_mac: "${IPV6_ROUTER_MAC}"
EOF
    fi
fi

# TCP flags
cat >> "$CONFIG_FILE" << EOF
  tcp:
    local_flag: ${LOCAL_FLAGS_YAML}
EOF

if [[ "$MODE" == "2" ]]; then
    cat >> "$CONFIG_FILE" << EOF
    remote_flag: ${REMOTE_FLAGS_YAML}
EOF
fi

# PCAP buffer
if [[ "$CUSTOM_PCAP" =~ ^[Yy]$ ]]; then
    cat >> "$CONFIG_FILE" << EOF
  pcap:
    sockbuf: ${PCAP_SOCKBUF}
EOF
fi

# Server address for client
if [[ "$MODE" == "2" ]]; then
    cat >> "$CONFIG_FILE" << EOF

server:
  addr: "${SERVER_IP}:${SERVER_PORT}"
EOF
fi

# Transport configuration
cat >> "$CONFIG_FILE" << EOF

transport:
  protocol: "kcp"
  conn: ${CONN_COUNT}
EOF

# Buffer settings (if we had asked for them, could add here)
# if [[ "$CUSTOM_BUFFERS" == "y" ]]; then
#   cat >> "$CONFIG_FILE" << EOF
#   tcpbuf: ${TCP_BUF}
#   udpbuf: ${UDP_BUF}
# EOF
# fi

# KCP configuration
cat >> "$CONFIG_FILE" << EOF
  kcp:
    mode: "${KCP_MODE}"
EOF

# Manual KCP parameters
if [[ "$KCP_MODE" == "manual" ]]; then
    cat >> "$CONFIG_FILE" << EOF
    nodelay: ${KCP_NODELAY}
    interval: ${KCP_INTERVAL}
    resend: ${KCP_RESEND}
    nocongestion: ${KCP_NOCONGESTION}
    wdelay: ${KCP_WDELAY}
    acknodelay: ${KCP_ACKNODELAY}
    mtu: ${KCP_MTU}
EOF
    if [[ -n "$KCP_RCVWND" ]]; then
        echo "    rcvwnd: ${KCP_RCVWND}" >> "$CONFIG_FILE"
    fi
    if [[ -n "$KCP_SNDWND" ]]; then
        echo "    sndwnd: ${KCP_SNDWND}" >> "$CONFIG_FILE"
    fi
fi

# Encryption
cat >> "$CONFIG_FILE" << EOF
    block: "${ENCRYPTION_ALGO}"
    key: "${SECRET}"
EOF

# FEC configuration
if [[ "$ENABLE_FEC" =~ ^[Yy]$ ]]; then
    cat >> "$CONFIG_FILE" << EOF
  dshard: ${DSHARD}
  pshard: ${PSHARD}
EOF
fi

print_success "Configuration saved to $CONFIG_FILE"

# ========== FIREWALL CONFIGURATION ==========
print_header "FIREWALL CONFIGURATION"

read -p "Configure iptables rules? (Y/n): " CONFIGURE_IPTABLES
CONFIGURE_IPTABLES=${CONFIGURE_IPTABLES:-Y}

if [[ "$CONFIGURE_IPTABLES" =~ ^[Yy]$ ]]; then
    print_step "Setting up iptables rules for port $PORT..."
    
    # Remove any existing rules for this port
    iptables -t raw -D PREROUTING -p tcp --dport ${PORT} -j NOTRACK 2>/dev/null || true
    iptables -t raw -D OUTPUT -p tcp --sport ${PORT} -j NOTRACK 2>/dev/null || true
    iptables -t mangle -D OUTPUT -p tcp --sport ${PORT} --tcp-flags RST RST -j DROP 2>/dev/null || true
    
    # Add new rules
    iptables -t raw -A PREROUTING -p tcp --dport ${PORT} -j NOTRACK
    iptables -t raw -A OUTPUT -p tcp --sport ${PORT} -j NOTRACK
    iptables -t mangle -A OUTPUT -p tcp --sport ${PORT} --tcp-flags RST RST -j DROP
    
    print_success "Added NOTRACK and RST drop rules"
    
    # Alternative rules option
    read -p "Also add INPUT/OUTPUT ACCEPT rules? (y/N): " ADD_ALT_RULES
    if [[ "$ADD_ALT_RULES" =~ ^[Yy]$ ]]; then
        iptables -t filter -A INPUT -p tcp --dport ${PORT} -j ACCEPT
        iptables -t filter -A OUTPUT -p tcp --sport ${PORT} -j ACCEPT
        print_success "Added alternative ACCEPT rules"
    fi
    
    # Save rules
    read -p "Make iptables rules persistent? (Y/n): " SAVE_IPTABLES
    SAVE_IPTABLES=${SAVE_IPTABLES:-Y}
    if [[ "$SAVE_IPTABLES" =~ ^[Yy]$ ]]; then
        if command -v netfilter-persistent > /dev/null; then
            netfilter-persistent save > /dev/null 2>&1
            print_success "Rules saved persistently via netfilter-persistent"
        elif command -v iptables-save > /dev/null; then
            mkdir -p /etc/iptables
            iptables-save > /etc/iptables/rules.v4
            print_success "Rules saved to /etc/iptables/rules.v4"
        else
            print_warning "Could not find iptables-save. Rules are not persistent."
        fi
    fi
else
    print_warning "Skipping iptables configuration"
    echo "   You must manually configure firewall rules for paqet to work properly."
fi

# ========== SYSTEMD SERVICE ==========
print_header "SERVICE SETUP"

print_step "Creating systemd service..."

cat > /etc/systemd/system/paqet.service << EOF
[Unit]
Description=Paqet ${ROLE} Service
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/paqet run -c ${CONFIG_FILE}
Restart=always
RestartSec=3
User=root
LimitNOFILE=65536

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable paqet > /dev/null 2>&1

print_success "Systemd service created and enabled"

# ========== FINALIZATION ==========
print_header "INSTALLATION COMPLETE"

# Summary
echo -e "\e[1;36m"
cat << "EOF"
 ██████╗ ███████╗ █████╗ ███████╗██╗   ██╗
 ██╔══██╗██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝
 ██████╔╝█████╗  ███████║███████╗ ╚████╔╝ 
 ██╔═══╝ ██╔══╝  ██╔══██║╚════██║  ╚██╔╝  
 ██║     ███████╗██║  ██║███████║   ██║   
 ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   
EOF
echo -e "\e[0m"

echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"
echo -e "\e[1;37m               INSTALLATION SUMMARY\e[0m"
echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"
echo ""
echo -e "\e[1;34m✓ Mode:\e[0m            $ROLE"
echo -e "\e[1;34m✓ Config File:\e[0m     $CONFIG_FILE"
echo -e "\e[1;34m✓ Port:\e[0m            $PORT"
echo -e "\e[1;34m✓ Log Level:\e[0m       $LOG_LEVEL"
echo -e "\e[1;34m✓ Encryption:\e[0m      $ENCRYPTION_ALGO"
echo -e "\e[1;34m✓ KCP Mode:\e[0m        $KCP_MODE"
echo -e "\e[1;34m✓ Connections:\e[0m     $CONN_COUNT"

if [[ "$MODE" == "1" ]]; then
    echo -e "\e[1;34m✓ Server Secret:\e[0m   $SECRET"
    echo ""
    echo -e "\e[1;33mIMPORTANT: Share this secret with your clients!\e[0m"
else
    echo -e "\e[1;34m✓ Server:\e[0m         $SERVER_IP:$SERVER_PORT"
    if [[ "$ENABLE_SOCKS5" =~ ^[Yy]$ ]]; then
        echo -e "\e[1;34m✓ SOCKS5 Proxy:\e[0m   $SOCKS_LISTEN:$SOCKS_PORT"
    fi
    if [[ "$ENABLE_FORWARDING" =~ ^[Yy]$ ]]; then
        echo -e "\e[1;34m✓ Port Forwarding:\e[0m $FORWARD_COUNT rule(s)"
    fi
fi

echo ""
echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"
echo -e "\e[1;37m              SERVICE MANAGEMENT COMMANDS\e[0m"
echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"
echo ""
echo -e "\e[1;36m  Start service:\e[0m    systemctl start paqet"
echo -e "\e[1;36m  Stop service:\e[0m     systemctl stop paqet"
echo -e "\e[1;36m  Check status:\e[0m     systemctl status paqet"
echo -e "\e[1;36m  View logs:\e[0m        journalctl -u paqet -f"
echo -e "\e[1;36m  Test connection:\e[0m  curl --proxy socks5h://127.0.0.1:1080 https://httpbin.org/ip"
echo ""
echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"

# Start service
read -p "Start paqet service now? (Y/n): " START_SERVICE
START_SERVICE=${START_SERVICE:-Y}

if [[ "$START_SERVICE" =~ ^[Yy]$ ]]; then
    print_step "Starting paqet service..."
    systemctl restart paqet
    sleep 2
    
    # Check status
    if systemctl is-active --quiet paqet; then
        print_success "Paqet service is running"
        echo ""
        echo -e "\e[1;32mService status:\e[0m"
        systemctl status paqet --no-pager -l | head -20
    else
        print_warning "Service may not be running properly"
        echo "Check logs with: journalctl -u paqet -f"
    fi
else
    print_warning "Service not started automatically"
    echo "Start manually with: systemctl start paqet"
fi

echo ""
echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"
echo -e "\e[1;32m         EaSy PaQeT Installation Complete!\e[0m"
echo -e "\e[1;35m══════════════════════════════════════════════════════════\e[0m"
echo ""
