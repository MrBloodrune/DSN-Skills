# Scripted SSH Examples

Non-interactive SSH command execution patterns for FortiGate automation.

## Basic Pattern

```bash
echo 'config system console
set output standard
end
<COMMANDS>' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T user@<firewall-ip> 2>/dev/null
```

**Key elements:**
- Disable paging first (`config system console...`)
- Use `-T` to disable pseudo-TTY
- Use `2>/dev/null` to suppress SSH warnings
- Pipe commands via echo

## System Status Check

```bash
echo 'config system console
set output standard
end
get system status' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

**Output:**
```
LTRKAR02-DF04 # Version: FortiGate-200F v7.6.4,build3596,250820 (GA.F)
Hostname: LTRKAR02-DF04
Current HA mode: a-p, primary
Cluster uptime: 57 days, 21 hours, 56 minutes, 32 seconds
```

## View Specific Policy

```bash
echo 'config system console
set output standard
end
show firewall policy 55' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

## Search Policies with Grep

```bash
echo 'config system console
set output standard
end
show firewall policy' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null | grep -B5 -A20 "IPSEC-SAML"
```

## Check Address Object

```bash
echo 'config system console
set output standard
end
show firewall address Gitlab-DEVOPS' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

**Output:**
```
config firewall address
    edit "Gitlab-DEVOPS"
        set subnet 10.103.8.10 255.255.255.255
    next
end
```

## Check Address Group

```bash
echo 'config system console
set output standard
end
show firewall addrgrp IPSEC-IPv4-Split' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

## Check VPN Split-Tunnel Config

```bash
echo 'config system console
set output standard
end
show vpn ipsec phase1-interface IPSEC-SAML' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

Look for: `set ipv4-split-include "<group-name>"`

## Check Routing

```bash
echo 'config system console
set output standard
end
get router info routing-table all' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null | grep -E "10.103.8|10.101.3"
```

**Output:**
```
C       10.101.3.0/24 is directly connected, VM_MGMT
C       10.103.8.0/24 is directly connected, DEVOPS
```

## Ping from FortiGate

```bash
echo 'config system console
set output standard
end
execute ping-options source 10.103.8.1
execute ping 10.103.8.10' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

## VPN Tunnel Status

```bash
echo 'config system console
set output standard
end
get vpn ipsec tunnel summary' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null | grep -A5 "IPSEC-SAML"
```

## Session Debugging

```bash
echo 'config system console
set output standard
end
diagnose sys session filter src 10.212.135.1
diagnose sys session filter dst 10.103.8.10
diagnose sys session list' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

## Non-Standard SSH Port

For firewalls on non-standard ports (e.g., 5022):

```bash
echo 'config system console
set output standard
end
get system status' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T -p 5022 admin@10.221.28.240 2>/dev/null
```

## Interface Status

```bash
echo 'config system console
set output standard
end
get system interface | grep -A10 DEVOPS' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

## Configuration Changes via Script

### Create Address Object

```bash
echo 'config firewall address
edit "new-server"
set subnet 10.103.8.50 255.255.255.255
set comment "New application server"
next
end' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

### Add to Address Group

```bash
echo 'config firewall addrgrp
edit "IPSEC-IPv4-Split"
append member "new-server"
next
end' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

### Add Service to Policy

```bash
echo 'config firewall policy
edit 55
append service "TCP-8080"
next
end' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```
