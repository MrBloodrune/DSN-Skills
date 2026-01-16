# FortiGate Troubleshooting Guide

Diagnostic procedures for connectivity, policy, and traffic flow issues.

## Connectivity Troubleshooting

### Basic Connectivity Check

1. Ping from FortiGate to target:
```
execute ping <target-ip>
```

2. Ping with specific source:
```
execute ping-options source <interface-ip>
execute ping <target-ip>
```

3. Check routing:
```
get router info routing-table details <target-ip>
```

### Verify Interface Status

```
get system interface | grep -A10 <interface-name>
```

Check for:
- `status: up`
- Correct IP assignment
- Proper VLAN tagging

## Session Debugging

### Filter Sessions

Set filters before listing:
```
diagnose sys session filter dst <ip>
diagnose sys session filter src <ip>
diagnose sys session filter dport <port>
```

### View Filtered Sessions
```
diagnose sys session list
```

Output shows:
- Protocol and state
- Source/destination IPs and ports
- Policy ID that matched
- Packet/byte counts
- NPU offload status

### Clear Sessions
```
diagnose sys session clear
```

Clears sessions matching current filter.

### Reset Filter
```
diagnose sys session filter clear
```

## Traffic Flow Debug

### Enable Flow Debug

```
diagnose debug reset
diagnose debug flow filter addr <ip>
diagnose debug flow show function-name enable
diagnose debug flow trace start <count>
diagnose debug enable
```

### Generate Traffic

From another device, send traffic to trigger the trace.

### Interpret Output

Key functions to watch:
- `vd_find_by_id` - Virtual domain lookup
- `ip_session_lookup` - Session table check
- `fw_forward_handler` - Firewall decision
- `__ip_route_output` - Route lookup
- `ipsec_output` - VPN encapsulation

### Disable Flow Debug

```
diagnose debug disable
diagnose debug flow trace stop
diagnose debug reset
```

## Packet Capture

### Syntax
```
diagnose sniffer packet <interface> '<filter>' <verbosity> <count>
```

### Verbosity Levels

- `1` - Header only
- `2` - Header + first 16 bytes
- `3` - Header + full packet hex
- `4` - Header + interface name
- `5` - Header + full packet hex + interface name
- `6` - Header + full packet hex + interface name + timestamp

### Filter Examples

Specific host:
```
diagnose sniffer packet any 'host 10.103.8.10' 4 100
```

Host and port:
```
diagnose sniffer packet any 'host 10.103.8.10 and port 443' 4 50
```

Between two hosts:
```
diagnose sniffer packet any 'host 10.1.1.1 and host 10.2.2.2' 4 100
```

Specific interface:
```
diagnose sniffer packet DEVOPS 'host 10.103.8.10' 4 50
```

ICMP only:
```
diagnose sniffer packet any 'icmp' 4 20
```

### Stop Capture

Press `Ctrl+C` or wait for packet count to complete.

## Policy Troubleshooting

### Check Policy Match

1. View all policies with traffic counters:
```
get firewall policy
```

2. Check specific policy:
```
show firewall policy <id>
get firewall policy <id>
```

3. Look for hit counts - if zero, policy not matching.

### Policy Order

Policies match top-to-bottom. Check if more specific policy is above.

### Common Policy Issues

**Implicit Deny:**
- Traffic not matching any policy = denied
- Enable logging on implicit deny to see dropped traffic

**Wrong Interface:**
- `srcintf` must match ingress interface
- `dstintf` must match egress interface

**Address Object Mismatch:**
- Verify address objects contain expected IPs
- Check address group membership

## Common Issues

### Traffic Blocked - No Session

Symptoms:
- Ping/connection fails
- No session in session table
- Flow debug shows policy deny

Resolution:
1. Check firewall policy exists for traffic
2. Verify interfaces are correct
3. Check address objects match traffic
4. Verify service ports allowed

### Traffic Blocked - Session Exists But Times Out

Symptoms:
- Session exists with packets TX but not RX
- One-way traffic

Resolution:
1. Check return path routing
2. Verify NAT settings if applicable
3. Check for asymmetric routing
4. Verify remote firewall/host allows return traffic

### VPN Traffic Not Reaching Destination

Symptoms:
- Tunnel up, client has routes
- Traffic enters tunnel but no response
- Zero sessions on FortiGate for destination

Resolution:
1. Verify traffic actually entering tunnel (client-side)
2. Check split-tunnel includes destination network
3. Reconnect VPN to get updated routes
4. Check firewall policy for tunnel interface

### Asymmetric Routing

Symptoms:
- Traffic arrives but replies take different path
- Stateful inspection drops reply
- Session shows TX but no RX

Resolution:
1. Enable asymmetric routing (not recommended):
```
config system settings
set asymroute enable
end
```

2. Better: Fix routing on destination host
- Add policy-based routing for source-based replies
- Ensure replies egress same interface as ingress

### High Availability Sync Issues

Symptoms:
- Sessions not syncing to standby
- Failover causes connection drops

Resolution:
```
diagnose sys ha checksum show
diagnose sys ha status
execute ha sync stop
execute ha sync start
```

## Debug Commands Summary

| Purpose | Command |
|---------|---------|
| Flow trace | `diagnose debug flow trace start N` |
| Session list | `diagnose sys session list` |
| Packet capture | `diagnose sniffer packet ...` |
| IKE debug | `diagnose debug application ike -1` |
| Clear debug | `diagnose debug reset` |
| Enable debug | `diagnose debug enable` |
| Disable debug | `diagnose debug disable` |
