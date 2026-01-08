# Networking Basics Notes

## 1. Core Concepts

### TCP vs UDP
- **TCP (Transmission Control Protocol)**
  - Connection-oriented (3-way handshake)
  - Reliable: guaranteed delivery, ordered packets
  - Error checking & retransmission
  - Use case: HTTP, HTTPS, SSH, FTP
  - Overhead lebih besar

- **UDP (User Datagram Protocol)**
  - Connectionless (no handshake)
  - Unreliable: no guarantee delivery
  - No error checking, no retransmission
  - Use case: DNS, streaming, gaming, VoIP
  - Overhead lebih kecil, lebih cepat

### Ports & Sockets
- **Port**: logical endpoint untuk komunikasi (0-65535)
  - Well-known ports: 0-1023 (HTTP:80, HTTPS:443, SSH:22, DNS:53)
  - Registered ports: 1024-49151
  - Dynamic/private ports: 49152-65535
- **Socket**: kombinasi IP address + port + protocol
  - Example: `10.0.0.100:22` (SSH)
  - Format: `IP:PORT`

### DNS (Domain Name System)
- **Record Types**:
  - **A**: IPv4 address (example.com → 93.184.216.34)
  - **AAAA**: IPv6 address (example.com → 2606:2800:220:1:248:1893:25c8:1946)
  - **CNAME**: Canonical name (alias) (www → example.com)
  - **TXT**: Text records (SPF, DKIM, verification)
  - **MX**: Mail exchange
  - **NS**: Name server

- **DNS Propagation**: waktu yang dibutuhkan untuk DNS changes tersebar ke semua DNS servers (biasanya 24-48 jam, tapi bisa lebih cepat)

- **DNS Resolver**: service yang translate domain ke IP
  - systemd-resolved (modern Linux)
  - /etc/resolv.conf (traditional)

### HTTP/HTTPS
- **HTTP (Hypertext Transfer Protocol)**
  - Port 80
  - Plain text (tidak encrypted)
  - Vulnerable to man-in-the-middle attacks

- **HTTPS (HTTP Secure)**
  - Port 443
  - Encrypted dengan TLS/SSL
  - Certificate-based authentication
  - Modern standard untuk web

### TLS/SSL Certificates
- **Purpose**: encrypt data + verify identity
- **Components**:
  - Subject: domain yang di-protect (CN=example.com)
  - Issuer: Certificate Authority (CA) yang issue cert
  - Validity: notBefore & notAfter dates
  - Public key: untuk encryption
- **Let's Encrypt**: free, automated CA
- **Certificate chain**: Root CA → Intermediate CA → End certificate

---

## 2. Debug Tools

### curl - HTTP client
```bash
curl https://example.com                    # GET request
curl -I https://example.com                 # Headers only (HEAD request)
curl -v https://example.com                 # Verbose (show handshake)
curl -H "Authorization: Bearer token" url   # Custom headers
curl -X POST -d "data" url                  # POST request
curl -o file.html https://example.com       # Save to file
```

**Key flags**:
- `-I` / `--head`: headers only
- `-v` / `--verbose`: show request/response details
- `-H`: custom header
- `-X`: HTTP method (GET, POST, PUT, DELETE)
- `-d`: data untuk POST
- `-o`: output file

### dig - DNS lookup
```bash
dig example.com                    # Default A record
dig +short example.com             # Short output (IP only)
dig AAAA example.com               # IPv6
dig TXT example.com                # TXT records
dig @8.8.8.8 example.com           # Query specific DNS server
dig +trace example.com             # Trace DNS resolution path
```

**Alternative**: `nslookup example.com`

### ss - Socket statistics
```bash
ss -tulpen                         # All TCP/UDP listening ports
ss -t                              # TCP only
ss -u                              # UDP only
ss -l                              # Listening sockets
ss -p                              # Show process
ss -n                              # Numeric (no name resolution)
```

**Flags explained**:
- `-t`: TCP
- `-u`: UDP
- `-l`: listening
- `-p`: process
- `-e`: extended info
- `-n`: numeric (faster, no DNS lookup)

**Alternative**: `netstat -tulpen` (older tool)

### openssl - TLS/SSL debugging
```bash
# Check certificate
openssl s_client -connect example.com:443 -servername example.com

# Extract cert info
echo | openssl s_client -connect example.com:443 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates

# Check cert expiry
echo | openssl s_client -connect example.com:443 2>/dev/null \
  | openssl x509 -noout -enddate
```

### traceroute / mtr - Network path tracing
```bash
traceroute example.com             # Show route to destination
traceroute -n example.com          # Numeric (no DNS lookup)
mtr example.com                    # Interactive traceroute
mtr -r -c 10 example.com           # Report mode, 10 cycles
```

**What it shows**:
- Each hop (router) between you and destination
- Latency per hop
- Packet loss per hop
- Useful untuk diagnose network issues

### tcpdump - Packet capture
```bash
tcpdump -i eth0                    # Capture on interface eth0
tcpdump -i any port 80             # Capture HTTP traffic
tcpdump -i any host 1.1.1.1        # Capture traffic to/from IP
tcpdump -w capture.pcap            # Save to file
tcpdump -r capture.pcap            # Read from file
```

**Common filters**:
- `port 80`: HTTP
- `port 443`: HTTPS
- `host 1.1.1.1`: specific IP
- `tcp`: TCP only
- `udp`: UDP only

---

## 3. Firewall & Security

### UFW (Uncomplicated Firewall)
```bash
sudo ufw status                    # Check status
sudo ufw status verbose            # Detailed status
sudo ufw enable                    # Enable firewall
sudo ufw disable                   # Disable firewall

# Allow/deny rules
sudo ufw allow 22/tcp              # Allow SSH
sudo ufw allow 80                  # Allow HTTP
sudo ufw allow 443                 # Allow HTTPS
sudo ufw deny 3306                 # Deny MySQL
sudo ufw delete allow 80           # Remove rule

# Default policies
sudo ufw default deny incoming     # Block all incoming
sudo ufw default allow outgoing    # Allow all outgoing
```

**Best practice**:
- Default deny incoming
- Default allow outgoing
- Explicitly allow only needed ports

### iptables/nftables
- **iptables**: traditional Linux firewall (older)
- **nftables**: modern replacement for iptables
- UFW adalah frontend untuk iptables/nftables (easier to use)

```bash
# iptables
sudo iptables -L                   # List rules
sudo iptables -S                   # List rules (save format)

# nftables
sudo nft list ruleset              # List all rules
```

### Reverse Proxy Concepts
- **Purpose**: 
  - Hide backend servers
  - Load balancing
  - SSL termination
  - Caching
  - Security (WAF)

- **Common reverse proxies**:
  - NGINX
  - Apache
  - Traefik
  - HAProxy
  - Caddy

- **Forwarding headers**:
  - `X-Forwarded-For`: original client IP
  - `X-Forwarded-Proto`: original protocol (http/https)
  - `X-Forwarded-Host`: original host header
  - `X-Real-IP`: real client IP

---

## 4. Network Interfaces & Routing

### ip command
```bash
ip addr                            # Show all interfaces & IPs
ip -br addr                        # Brief format
ip link                            # Show link status
ip route                           # Show routing table
ip route get 8.8.8.8               # Show route to specific IP
```

**Common interfaces**:
- `lo`: loopback (127.0.0.1)
- `eth0` / `ens18`: physical ethernet
- `wlan0`: wireless
- `docker0`: Docker bridge
- `br-*`: custom bridges
- `veth*`: virtual ethernet (containers)
- `tailscale0`: VPN interface

### Routing
- **Default gateway**: router untuk traffic ke internet
- **Routing table**: map network destinations ke interfaces
- Format: `destination via gateway dev interface`

Example:
```
default via 10.0.0.1 dev eth0
10.0.0.0/24 dev eth0 scope link
```

---

## 5. systemd-resolved (Modern DNS)

### Configuration
- **Config file**: `/etc/systemd/resolved.conf`
- **Runtime status**: `resolvectl status`
- **Stub resolver**: 127.0.0.53:53

### Modes
- **stub**: systemd-resolved listens on 127.0.0.53
- **static**: use /etc/resolv.conf directly
- **foreign**: external DNS manager

### Commands
```bash
resolvectl status                  # Show DNS config per interface
resolvectl query example.com       # Query DNS
resolvectl flush-caches            # Clear DNS cache
```

---

## 6. Common Network Issues & Troubleshooting

### Connection refused
- Service not running
- Firewall blocking
- Wrong port
- Check: `ss -tulpen | grep <port>`

### Timeout
- Network unreachable
- Firewall dropping packets
- Service overloaded
- Check: `ping`, `traceroute`, `mtr`

### DNS resolution failed
- DNS server down
- Wrong DNS config
- Domain doesn't exist
- Check: `dig`, `resolvectl status`

### TLS/SSL errors
- Certificate expired
- Certificate mismatch (wrong domain)
- Self-signed certificate
- Check: `openssl s_client`, `curl -v`

---

## 7. Docker Networking (Bonus)

### Docker network types
- **bridge**: default, isolated network
- **host**: use host network directly
- **none**: no network
- **custom bridge**: user-defined bridge

### Docker networking commands
```bash
docker network ls                  # List networks
docker network inspect bridge      # Inspect network
docker network create mynet        # Create network
```

### Port mapping
- `-p 8080:80`: map host:8080 → container:80
- `-p 127.0.0.1:8080:80`: bind to localhost only
- `--network host`: use host network (no isolation)

---

## 8. Security Best Practices

1. **Firewall**:
   - Enable firewall (ufw/iptables)
   - Default deny incoming
   - Allow only necessary ports
   - Regular audit of rules

2. **TLS/SSL**:
   - Always use HTTPS for web services
   - Use valid certificates (Let's Encrypt)
   - Disable old TLS versions (< TLS 1.2)
   - Strong cipher suites

3. **SSH**:
   - Disable password auth (key-only)
   - Change default port (optional)
   - Use fail2ban for brute-force protection
   - Limit SSH access by IP (if possible)

4. **Monitoring**:
   - Monitor open ports regularly
   - Check for unexpected listening services
   - Monitor firewall logs
   - Alert on suspicious connections

---

## 9. Quick Reference

### Check listening ports
```bash
ss -tulpen | grep LISTEN
netstat -tulpen | grep LISTEN
lsof -i -P -n | grep LISTEN
```

### Check if port is open
```bash
nc -zv example.com 80              # netcat
telnet example.com 80              # telnet
curl -v telnet://example.com:80    # curl
```

### Check DNS
```bash
dig +short example.com
nslookup example.com
host example.com
```

### Check HTTP/HTTPS
```bash
curl -I https://example.com
curl -v https://example.com
wget --spider https://example.com
```

### Check TLS cert
```bash
echo | openssl s_client -connect example.com:443 2>/dev/null \
  | openssl x509 -noout -text
```

---

## References
- Lab: `labs/02-networking/`
- Script: `labs/02-networking/scripts/netcheck.sh`
- Output: `labs/02-networking/netcheck.out`
- Server: Ubuntu 24.04.2 LTS
