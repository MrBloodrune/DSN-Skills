# FortiGate Command Reference

Complete CLI command reference for FortiGate firewalls.

## System Commands

### System Status
```
get system status
```

### HA Status
```
get system ha status
```

### Interface Status
```
get system interface physical
get system interface | grep -A5 <interface-name>
```

### ARP Table
```
get system arp
```

### Session Table
```
get system session list
get system session list | grep <ip>
```

## Firewall Policy Commands

### List All Policies
```
show firewall policy
```

### Show Single Policy
```
show firewall policy <id>
```

### Policy by Name
```
show firewall policy | grep -B5 -A20 '<name>'
```

### Create Policy
```
config firewall policy
edit 0
set name "<name>"
set srcintf "<src>"
set dstintf "<dst>"
set srcaddr "<addr>"
set dstaddr "<addr>"
set action accept
set schedule "always"
set service "<svc>"
set logtraffic all
next
end
```

### Modify Policy
```
config firewall policy
edit <id>
set <field> <value>
next
end
```

### Append to Policy
```
config firewall policy
edit <id>
append service <service>
append srcaddr <address>
next
end
```

### Delete Policy
```
config firewall policy
delete <id>
end
```

## Address Object Commands

### List All Addresses
```
show firewall address
```

### Show Single Address
```
show firewall address <name>
```

### Create Address (Subnet)
```
config firewall address
edit "<name>"
set subnet <ip> <mask>
set comment "<description>"
next
end
```

### Create Address (FQDN)
```
config firewall address
edit "<name>"
set type fqdn
set fqdn "<domain>"
next
end
```

### Create Address (Range)
```
config firewall address
edit "<name>"
set type iprange
set start-ip <ip>
set end-ip <ip>
next
end
```

## Address Group Commands

### Show Group
```
show firewall addrgrp <name>
```

### Create Group
```
config firewall addrgrp
edit "<name>"
set member "<addr1>" "<addr2>"
next
end
```

### Add to Group
```
config firewall addrgrp
edit "<name>"
append member "<address>"
next
end
```

### Remove from Group
```
config firewall addrgrp
edit "<name>"
unselect member "<address>"
next
end
```

## Service Commands

### List Services
```
show firewall service custom
```

### Create TCP Service
```
config firewall service custom
edit "<name>"
set tcp-portrange <port>
next
end
```

### Create UDP Service
```
config firewall service custom
edit "<name>"
set udp-portrange <port>
next
end
```

### Create TCP/UDP Range
```
config firewall service custom
edit "<name>"
set tcp-portrange <start>-<end>
next
end
```

## VPN Commands

### Tunnel Summary
```
get vpn ipsec tunnel summary
```

### Tunnel Details
```
get vpn ipsec tunnel details
diagnose vpn tunnel list name <tunnel-name>
```

### Phase1 Configuration
```
show vpn ipsec phase1-interface
show vpn ipsec phase1-interface <name>
```

### Phase2 Configuration
```
show vpn ipsec phase2-interface
```

### Bring Tunnel Up
```
diagnose vpn tunnel up <phase1-name>
```

### Clear and Restart Tunnel
```
diagnose vpn tunnel down <phase1-name>
diagnose vpn tunnel up <phase1-name>
```

### Flush IKE Gateway
```
diagnose vpn ike gateway flush name <phase1-name>
```

## Routing Commands

### Full Routing Table
```
get router info routing-table all
```

### Static Routes
```
get router info routing-table static
```

### Connected Routes
```
get router info routing-table connected
```

### Route Details
```
get router info routing-table details <network>
```

### Add Static Route
```
config router static
edit 0
set dst <network> <mask>
set gateway <gw-ip>
set device "<interface>"
next
end
```

### Add Route via Tunnel
```
config router static
edit 0
set dst <network> <mask>
set device "<tunnel-name>"
next
end
```

## Diagnostic Commands

### Ping
```
execute ping <ip>
```

### Ping with Source
```
execute ping-options source <ip>
execute ping <dest-ip>
```

### Traceroute
```
execute traceroute <ip>
```

### DNS Lookup
```
execute nslookup <hostname>
```

### Debug Flow (Traffic Trace)
```
diagnose debug reset
diagnose debug flow filter addr <ip>
diagnose debug flow show function-name enable
diagnose debug flow trace start 10
diagnose debug enable
```

Wait for traffic, then:
```
diagnose debug disable
diagnose debug flow trace stop
```

### Packet Sniffer
```
diagnose sniffer packet <interface> '<filter>' <verbosity> <count>
```

Example:
```
diagnose sniffer packet any 'host 10.103.8.10 and port 443' 4 10
```

Verbosity levels:
- `1` - Header only
- `4` - Header + interface name
- `6` - Header + hex + interface + timestamp

### Session Filter and Clear
```
diagnose sys session filter dst <ip>
diagnose sys session list
diagnose sys session clear
diagnose sys session filter clear
```

## Log Commands

### Traffic Log
```
execute log filter category traffic
execute log display
```

### Event Log
```
execute log filter category event
execute log display
```

### Filter by Source
```
execute log filter field srcip <ip>
execute log display
```

## Configuration Management

### Show Running Config
```
show full-configuration
```

### Backup Config
```
execute backup config tftp <filename> <tftp-server-ip>
```

### Compare Revisions
```
execute revision diff <rev1> <rev2>
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
