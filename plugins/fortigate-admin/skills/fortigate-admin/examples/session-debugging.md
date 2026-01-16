# Session Debugging Example

Real-world troubleshooting workflow for diagnosing connectivity issues.

## Scenario

VPN client (10.212.135.1) cannot reach GitLab server (10.103.8.10) despite:
- VPN tunnel being UP
- Routes installed on client
- Firewall policy existing

## Step 1: Verify Tunnel Status

```bash
echo 'config system console
set output standard
end
get vpn ipsec tunnel summary' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null | grep "IPSEC-SAML"
```

**Result:**
```
'IPSEC-SAML_0' 47.213.51.193:4500  selectors(total,up): 2/2  rx(pkt,err): 111946/524  tx(pkt,err): 106513/0
```

✅ Tunnel is UP with 2/2 selectors active.

## Step 2: Check Firewall Policy

```bash
echo 'config system console
set output standard
end
show firewall policy' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null | grep -B5 -A20 "DEVOPS"
```

**Result:**
```
edit 55
    set name "IPSEC-Access->DEVOPS"
    set srcintf "IPSEC-SAML"
    set dstintf "DEVOPS"
    set action accept
    set srcaddr "VPNPool-IPSEC_SAML"
    set dstaddr "Gitlab-DEVOPS"
    set service "PING" "PING6" "TCP-2222" "TCP-8080" "TCP-8443"
```

✅ Policy 55 exists and allows traffic.

## Step 3: Verify Address Object

```bash
echo 'config system console
set output standard
end
show firewall address Gitlab-DEVOPS' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

**Result:**
```
config firewall address
    edit "Gitlab-DEVOPS"
        set subnet 10.103.8.10 255.255.255.255
    next
end
```

✅ Address object correctly points to 10.103.8.10.

## Step 4: Check Split-Tunnel Configuration

```bash
echo 'config system console
set output standard
end
show vpn ipsec phase1-interface IPSEC-SAML' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null | grep split
```

**Result:**
```
set ipv4-split-include "IPSEC-IPv4-Split"
```

Check what networks are in the split-tunnel group:

```bash
echo 'config system console
set output standard
end
show firewall addrgrp IPSEC-IPv4-Split' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

**Result:**
```
set member "DC1-DEVOPS" ... (includes 10.103.8.0/24)
```

✅ Network is in split-tunnel.

## Step 5: Check Sessions

```bash
echo 'config system console
set output standard
end
diagnose sys session filter dst 10.103.8.10
diagnose sys session list' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

**Result:**
```
total session: 0
```

⚠️ **No sessions!** Traffic is not reaching the firewall.

## Step 6: Test from FortiGate Directly

```bash
echo 'config system console
set output standard
end
execute ping-options source 10.103.8.1
execute ping 10.103.8.10' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

**Result:**
```
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 0.4/0.6/1.5 ms
```

✅ FortiGate can reach the server. Layer 2/3 connectivity is working.

## Step 7: Check VPN Tunnel Selectors

```bash
echo 'config system console
set output standard
end
diagnose vpn tunnel list name IPSEC-SAML_0' | ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -T cshelton@10.101.5.1 2>/dev/null
```

**Key output:**
```
proxyid=IKEv2-v4 proto=0 sa=1
  src: 0:0.0.0.0-255.255.255.255:0
  dst: 0:10.212.135.1-10.212.135.1:0
```

## Diagnosis

- Firewall configuration is correct ✅
- FortiGate can reach destination ✅
- VPN tunnel is UP ✅
- But 0 sessions for destination ⚠️

**Root cause identified:** Traffic from VPN client is not being encrypted/tunneled despite routes being present. Issue is on client side (FortiClient) or tunnel negotiation.

## Resolution Steps

1. **Reconnect VPN** - Force tunnel renegotiation
2. **Flush IKE gateway:**
   ```bash
   diagnose vpn ike gateway flush name IPSEC-SAML
   ```
3. **Check FortiClient logs** for ESP encapsulation errors

## Alternative Root Cause: Asymmetric Routing

If the destination server has multiple interfaces, return traffic may go out a different path:

**Check server routing:**
- Inbound arrives on interface A
- Reply goes out default route on interface B
- FortiGate drops due to state mismatch

**Solution:** Configure policy-based routing on server to ensure replies exit same interface as requests arrived.
