
# 🚀 EaSy PaQeT

A beautiful, interactive installer for **Paqet** - a bidirectional packet-level proxy that ferries packets across forbidden boundaries using raw sockets.

<div align="center">
  
</div>

## ✨ Features

- 🔄 **Interactive Menu System** with persistent interface
- ⚡ **One-Click Installation** for both Server and Client modes
- 🔧 **Complete Configuration** with all Paqet options
- 📊 **Real-time Monitoring** (status, logs, connection testing)
- 🛡️ **Automatic Firewall Setup** with iptables configuration
- 📱 **Multi-architecture Support** (x86_64, ARM64, ARM32)
- 🗑️ **Safe Uninstaller** with confirmation

## 🚀 Quick Start

### One-Command Installation (Server or Client)

```bash
echo "📥 Downloading EaSy PaQeT installer..." && \
sudo bash -c "$(wget -q --show-progress -O- https://raw.githubusercontent.com/mehditohidi/EaSy-PaQeT/main/installer.sh)"
```
# Manual Installation
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/mehditohidi/EaSy-PaQeT/main/installer.sh)"
Manual Installation (Recommended)

```bash
wget https://raw.githubusercontent.com/mehditohidi/EaSy-PaQeT/main/installer.sh
```

# 2. Make it executable and run
chmod +x installer.sh
sudo ./installer.sh



### 📋 Prerequisites

Operating System: Linux (Debian/Ubuntu/RHEL/CentOS)
Architecture: x86_64, ARM64, or ARM32
Permissions: Root access (sudo)
Dependencies: Automatically installed by the script


### 🖥️ Installation Options

1. Install as SERVER

Creates a Paqet server that listens for incoming connections.

```bash
# The installer will guide you through:
# • Port selection (default: 9999)
# • Encryption key generation
# • Network configuration
# • Firewall setup
```

2. Install as CLIENT

Creates a Paqet client that connects to a server.

```bash
# You'll need:
# • Server IP address and port
# • Server secret key
# • Optional: SOCKS5 proxy configuration
```

After installation, you can run the installer again to access the management menu:

```text
╔════════════════════════════════════════════════╗
║             EaSy PaQeT MAIN MENU              ║
╚════════════════════════════════════════════════╝

1) Install as SERVER
2) Install as CLIENT
3) View Configuration
4) See Paqet STATUS
5) See Paqet Logs
6) Test Connection (Client Only)
7) Uninstall
8) Exit
```

### 🔧 Configuration Options

The installer supports all Paqet configuration options:

Category	Options	Description
Encryption	AES, Salsa20, ChaCha20, Blowfish, etc.	14+ encryption algorithms
KCP Modes	Normal, Fast, Fast2, Fast3, Manual	Transport optimization
TCP Flags	PA, S, A, SA, custom arrays	Packet flag cycling
Network	IPv4/IPv6, PCAP buffers, interface config	Network layer settings
Proxy	SOCKS5 with authentication	Client-side proxy setup
Port Forwarding	Multiple rules with protocols	Advanced routing


### 🛠️ Management Commands

After installation, manage Paqet with:

# Service management
```sudo systemctl start paqet```      # Start service
```sudo systemctl stop paqet```       # Stop service
```sudo systemctl restart paqet```    # Restart service
```sudo systemctl status paqet```     # Check status

# Log viewing
```sudo journalctl -u paqet -f```     # Follow logs in real-time
```sudo journalctl -u paqet -n 50```  # View last 50 log entries

# Configuration
```sudo cat /etc/paqet/server.yaml``` # View server config
```sudo cat /etc/paqet/client.yaml``` # View client config

🧹 Uninstallation

# Run the installer and choose option 7


# Or manually remove
```bash
sudo systemctl stop paqet
sudo rm -rf /etc/paqet /usr/local/bin/paqet
sudo rm /etc/systemd/system/paqet.service
```

📁 File Structure

```text
/etc/paqet/
├── server.yaml          # Server configuration
├── client.yaml          # Client configuration
/usr/local/bin/paqet     # Paqet binary
/etc/systemd/system/paqet.service  # Systemd service
```

🐛 Troubleshooting

Issue	Solution
Permission denied	Run with sudo
Service not starting	Check logs: journalctl -u paqet -f
Connection failed	Verify firewall rules and server IP
Binary not found	Re-run installer to download paqet
Config errors	Check YAML syntax in /etc/paqet/

🔒 Security Notes

⚠️ Important Security Considerations:

Never use standard ports (80, 443) for Paqet server
Keep your secret key secure - regenerate if compromised
Review iptables rules after installation
Use strong encryption (AES-256 recommended)
Monitor logs regularly for suspicious activity

🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

Fork the repository
Create your feature branch (git checkout -b feature/AmazingFeature)
Commit your changes (git commit -m 'Add some AmazingFeature')
Push to the branch (git push origin feature/AmazingFeature)
Open a Pull Request
📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments

Paqet - The original project by hanselime
All contributors and testers
The open-source community
⭐ Support

If you find this project useful, please give it a star on GitHub!

<div align="center"> <sub>Built with ❤️ by <a href="https://github.com/mehditohidi">mehditohidi</a></sub> </div>
