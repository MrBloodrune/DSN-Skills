# VPN/IPsec Reference

Comprehensive VPN tunnel management for FortiGate firewalls.

## Tunnel Status Commands

### Summary View
```
get vpn ipsec tunnel summary
```

Output shows: tunnel name, peer IP, selector count (total/up), rx/tx packets/errors.

### Detailed Tunnel Info
```
diagnose vpn tunnel list name <tunnel-name>
```

Shows:
- Tunnel state and connection info
- Phase2 selectors and SAs
- Encryption/decryption stats
- NPU offload status

### Phase1 Configuration
```
show vpn ipsec phase1-interface <name>
```

Key fields:
- `interface` - Outbound interface
- `ike-version` - IKEv1 or IKEv2
- `mode-cfg enable` - Client gets IP from FortiGate
- `ipv4-split-include` - Split tunnel address group
- `ipv4-start-ip` / `ipv4-end-ip` - Client IP pool

### Phase2 Configuration
```
show vpn ipsec phase2-interface
```

Shows traffic selectors (which networks can traverse tunnel).

## Dialup VPN (Remote Access)

### Check Split-Tunnel Configuration

Find the split-tunnel group:
```
show vpn ipsec phase1-interface <name> | grep split-include
```

View group members (networks routed through VPN):
```
show firewall addrgrp "<split-tunnel-group-name>"
```

### Add Network to Split-Tunnel

1. Create address object:
```
config firewall address
edit "New-Network"
set subnet 10.x.x.0 255.255.255.0
next
end
```

2. Add to split-tunnel group:
```
config firewall addrgrp
edit "<split-tunnel-group>"
append member "New-Network"
next
end
```

Clients must reconnect to receive new routes.

### View Active VPN Users

```
get vpn ipsec tunnel summary | grep <phase1-name>
```

Each `_N` suffix is a unique client connection.

## Site-to-Site VPN

### Check Tunnel Health
```
get vpn ipsec tunnel summary
```

Look for:
- `selectors(total,up): 2/2` - Both selectors up = healthy
- `rx/tx err` - Errors indicate issues

### Bring Tunnel Up
```
diagnose vpn tunnel up <phase1-name>
```

### Restart Tunnel
```
diagnose vpn tunnel down <phase1-name>
diagnose vpn tunnel up <phase1-name>
```

### Clear IKE Gateway
```
diagnose vpn ike gateway flush name <phase1-name>
```

Use when tunnel won't negotiate.

## Phase2 Selectors

### View Selectors
```
diagnose vpn tunnel list name <tunnel-name>
```

Look for `proxyid` sections:
```
proxyid=<name> proto=0 sa=1
  src: 0:0.0.0.0-255.255.255.255:0
  dst: 0:10.212.135.1-10.212.135.1:0
```

### Selector Meaning

For dialup VPNs with mode-cfg:
- `src: 0.0.0.0/0` = Any source allowed (remote networks)
- `dst: client-ip/32` = Only traffic TO client

For site-to-site:
- `src: local-network`
- `dst: remote-network`

## Troubleshooting VPN Issues

### Tunnel Not Coming Up

1. Check IKE negotiation:
```
diagnose debug application ike -1
diagnose debug enable
```

2. Verify Phase1 matches on both sides:
- IKE version
- Encryption/authentication proposals
- DH group
- Pre-shared key

3. Check connectivity to peer:
```
execute ping <peer-public-ip>
```

### Tunnel Up But No Traffic

1. Check selectors match traffic:
```
diagnose vpn tunnel list name <tunnel>
```

2. Verify firewall policy exists:
```
show firewall policy | grep -A20 "<tunnel-interface>"
```

3. Check routing:
```
get router info routing-table all | grep <remote-network>
```

### Split-Tunnel Not Working

1. Verify network in split-tunnel group
2. Check client received routes (client-side)
3. Reconnect VPN to get updated routes
4. Verify firewall policy allows traffic

### Asymmetric Routing Issues

If traffic arrives via tunnel but replies go different path:

1. Check destination host routing
2. May need policy-based routing on destination
3. Verify FortiGate has return route via tunnel

## VPN Monitoring

### Real-time Stats
```
diagnose vpn tunnel stat
```

### Debug IKE Negotiation
```
diagnose debug reset
diagnose debug application ike -1
diagnose debug enable
```

Stop with:
```
diagnose debug disable
```

### ESP Packet Debug
```
diagnose vpn tunnel esp-debug on
get vpn ipsec tunnel summary
diagnose vpn tunnel esp-debug off
```
