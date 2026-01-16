# DSN Environment Reference

Environment-specific FortiGate configurations for DSN managed networks.

## LTRKAR02-DF04 (DSN Core)

### Connection

| Property | Value |
|----------|-------|
| Hostname | LTRKAR02-DF04 |
| Model | FortiGate-200F |
| Firmware | FortiOS 7.6.4 |
| IP | 10.101.5.1 |
| SSH Port | 22 (standard) |
| HA Mode | Active-Passive (primary) |

```bash
ssh cshelton@10.101.5.1
```

### Key Interfaces

| Interface | Purpose | Subnet |
|-----------|---------|--------|
| VM_MGMT | VM management | 10.101.3.0/24 |
| DEVOPS | DevOps VLAN | 10.103.8.0/24 |
| HV_MGMT | Hypervisor management | 10.101.1.0/24 |

### VPN Configuration

**IPSEC-SAML (Dialup VPN):**
- Type: IKEv2 with SAML authentication
- Split-tunnel group: `IPSEC-IPv4-Split`
- Client pool: 10.212.135.0/24

**Site-to-Site Tunnels:**
| Tunnel | Remote | Selectors |
|--------|--------|-----------|
| FuseRural | HMBGAR01-DF01 | Various subnets |

### Key Address Groups

| Group | Purpose |
|-------|---------|
| IPSEC-IPv4-Split | Networks routed through VPN |
| VPN-Full-Access | Resources for VPN users |

---

## HMBGAR01-DF01/DF02 (FUSE)

### Connection

| Property | Value |
|----------|-------|
| Hostname | HMBGAR01-DF01 (Primary) |
| Model | FortiGate-61F |
| IP | 10.221.28.240 |
| SSH Port | **5022** (non-standard) |
| Credentials | 1Password `FUSE/FortiGate-Admin` |

```bash
ssh -p 5022 admin@10.221.28.240
```

Secondary: HMBGAR01-DF02 at 10.221.28.241:5022

### Key Interfaces

| Interface | Purpose | Subnet |
|-----------|---------|--------|
| MGMT | Management VLAN 500 | 10.205.0.0/24 |
| DHCP | DHCP VLAN 501 | 10.205.1.0/24 |
| DNS | DNS VLAN 502 | 10.205.2.0/24 |
| Telemetry | Telemetry VLAN 503 | 10.205.3.0/24 |
| Proxy | Proxy VLAN 504 | 10.205.4.0/24 |
| FuseConnect | WAN uplink | Public |
| DSN-DC1 | IPsec tunnel to DSN | Tunnel |

### VPN Configuration

**DSN-DC1 Tunnel:**
- Phase1: DSN-DC1
- Phase2: DSN-DC1
- Remote: 23.136.136.94 (LTRKAR02-DF04)
- Selectors: 0.0.0.0/0 ↔ 0.0.0.0/0

### Key Address Objects

| Name | Value | Purpose |
|------|-------|---------|
| LTRKAR02-PBS01 | 10.101.1.250/32 | PBS backup server |
| smx-rp-vm101 | 10.205.0.30/32 | Calix SMx VM |
| DSN-Jumpbox | 23.136.136.132/32 | DSN jumpbox |

### Key Address Groups

| Group | Purpose | Members |
|-------|---------|---------|
| Inet-Access-Group | Internet access | Objects needing outbound |
| VPN-DSN-Group | VPN destinations | DSN-Jumpbox, LTRKAR02-PBS01 |

### Key Policies

| ID | Name | Direction | Purpose |
|----|------|-----------|---------|
| 1 | INET-Temp | MGMT/Proxy → FuseConnect | Internet access |
| 2 | FuseRural->DSN | MGMT/Proxy → DSN-DC1 | Outbound to DSN via VPN |
| 8 | Proxmox-Backup access | DSN-DC1 → MGMT | PBS backup inbound |

### Key Services

| Name | Port | Purpose |
|------|------|---------|
| TCP-8006 | TCP/8006 | Proxmox Web UI |
| TCP-8007 | TCP/8007 | PBS API |
| TCP-3443 | TCP/3443 | Calix SMx |

---

## Quick Connection Reference

| Environment | Command |
|-------------|---------|
| DSN Core | `ssh cshelton@10.101.5.1` |
| FUSE Primary | `ssh -p 5022 admin@10.221.28.240` |
| FUSE Secondary | `ssh -p 5022 admin@10.221.28.241` |

## Scripted Command Pattern

```bash
# DSN Core
echo 'config system console
set output standard
end
<COMMANDS>' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null

# FUSE
echo 'config system console
set output standard
end
<COMMANDS>' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T -p 5022 admin@10.221.28.240 2>/dev/null
```
