---
name: FortiGate Administration
description: >
  This skill should be used when the user asks to "check firewall rules", "add firewall policy",
  "configure FortiGate", "check VPN tunnel", "view firewall policy", "add address object",
  "troubleshoot connectivity", "check routing", "add to address group", "check tunnel status",
  "debug traffic flow", "check HA status", "view sessions", "packet capture", "check split tunnel",
  or mentions FortiGate, FortiOS, IPsec tunnel, firewall configuration, or network policy management.
version: 1.0.0
---

# FortiGate Administration

Manage FortiGate firewalls via CLI for policy management, VPN operations, and network diagnostics.

## Connection Methods

### Scripted Commands (Recommended)

Execute commands via piped SSH to avoid interactive session issues:

```bash
echo 'config system console
set output standard
end
COMMANDS_HERE' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T user@firewall-ip 2>/dev/null
```

**Required flags:**
- `-T` — Disable pseudo-terminal (required for piping)
- `-o ConnectTimeout=10` — Timeout after 10 seconds
- `-o StrictHostKeyChecking=no` — Skip host key verification
- `2>/dev/null` — Suppress SSH warnings

**Always include paging disable** at start of command block:
```
config system console
set output standard
end
```

### Interactive Session

```bash
ssh user@firewall-ip
```

For non-standard ports:
```bash
ssh -p 5022 admin@firewall-ip
```

## Common Operations

### View System Status

```
get system status
```

Returns firmware version, serial number, HA status, uptime.

### View Firewall Policies

List all policies:
```
show firewall policy
```

View specific policy:
```
show firewall policy <id>
```

Search policies by pattern:
```
show firewall policy | grep -B5 -A20 "PATTERN"
```

### Create Firewall Policy

```
config firewall policy
edit 0
set name "Policy-Name"
set srcintf "SOURCE_ZONE"
set dstintf "DEST_ZONE"
set action accept
set srcaddr "ADDRESS_OBJECT"
set dstaddr "ADDRESS_OBJECT"
set schedule "always"
set service "SERVICE_NAME"
set logtraffic all
next
end
```

### Modify Existing Policy

Add service to policy:
```
config firewall policy
edit <id>
append service "SERVICE_NAME"
next
end
```

### Address Objects

Create subnet address:
```
config firewall address
edit "object-name"
set subnet 10.x.x.x 255.255.255.255
set comment "Description"
next
end
```

Create FQDN address:
```
config firewall address
edit "object-name"
set type fqdn
set fqdn "hostname.domain.com"
next
end
```

### Address Groups

View group members:
```
show firewall addrgrp "group-name"
```

Add member to group:
```
config firewall addrgrp
edit "group-name"
append member "object-name"
next
end
```

### Routing

View full routing table:
```
get router info routing-table all
```

View specific route:
```
get router info routing-table details <network>
```

### Interface Status

```
get system interface | grep -A10 <interface-name>
```

## VPN Operations

### Tunnel Status

View all tunnels:
```
get vpn ipsec tunnel summary
```

View tunnel details:
```
diagnose vpn tunnel list name <tunnel-name>
```

### Phase1/Phase2 Configuration

```
show vpn ipsec phase1-interface <name>
show vpn ipsec phase2-interface
```

### Check Split-Tunnel Routes

For dialup VPNs, check the split-tunnel address group:
```
show vpn ipsec phase1-interface <name> | grep split-include
show firewall addrgrp "<split-tunnel-group>"
```

### Tunnel Diagnostics

Bring tunnel up:
```
diagnose vpn tunnel up <phase1-name>
```

Clear and restart tunnel:
```
diagnose vpn tunnel down <phase1-name>
diagnose vpn tunnel up <phase1-name>
```

## Diagnostics

### Session Table

Filter and view sessions:
```
diagnose sys session filter dst <ip>
diagnose sys session list
```

Clear sessions:
```
diagnose sys session filter dst <ip>
diagnose sys session clear
```

### Debug Traffic Flow

```
diagnose debug reset
diagnose debug flow filter addr <ip>
diagnose debug flow show function-name enable
diagnose debug flow trace start 10
diagnose debug enable
```

Stop debug:
```
diagnose debug disable
diagnose debug flow trace stop
```

### Packet Capture

```
diagnose sniffer packet <interface> '<filter>' <verbosity> <count>
```

Example:
```
diagnose sniffer packet any 'host 10.103.8.10 and port 8007' 4 10
```

### Ping with Source

```
execute ping-options source <source-ip>
execute ping <destination-ip>
```

## HA Status

```
get system ha status
```

## Services

Create custom TCP service:
```
config firewall service custom
edit "TCP-8443"
set tcp-portrange 8443
next
end
```

## Additional Resources

### Reference Files

For detailed command syntax and advanced operations:
- **`references/commands.md`** - Complete CLI command reference
- **`references/vpn-ipsec.md`** - VPN tunnel management details
- **`references/troubleshooting.md`** - Diagnostic procedures
- **`references/environments.md`** - DSN environment-specific configurations

### Example Files

Working examples from real operations:
- **`examples/scripted-ssh.md`** - Automation patterns
- **`examples/session-debugging.md`** - Traffic flow debugging workflow
