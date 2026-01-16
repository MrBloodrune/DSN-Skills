---
name: DHCP Load Testing
description: Load test ISC Kea DHCP using perfdhcp. Use when asked to "load test DHCP", "stress test Kea", "test DHCP capacity", or validate DHCP infrastructure.
version: 1.0.0
---

# DHCP Load Testing

Procedures for load testing ISC Kea DHCP servers using perfdhcp from a test container.

## Infrastructure

| Component | Location | Details |
|-----------|----------|---------|
| Kea Server | dhcp-ct101 (CT 101) | 10.205.1.11, VLAN 501 |
| Test Container | loadtest-ct110 (CT 110) | 10.205.1.110, VLAN 501 |
| Subnet | 10.205.1.0/24 | Production DHCP subnet |

## Prerequisites

- Test container on same L2 network as Kea server
- perfdhcp copied from Kea server (not apt-installed)
- Sufficient pool space for test clients

## Quick Reference

| Test Type | Rate | Expected Result |
|-----------|------|-----------------|
| Baseline | 100/sec | <1% drops, <10ms latency |
| Capacity | 200/sec | <1% drops (safe max) |
| Stress | 250-500/sec | Find breaking point (~230/sec PostgreSQL limit) |

## Procedure

### 1. Copy perfdhcp from Kea Server

**Critical:** Copy binaries and libraries from Kea server - apt packages have dependency issues.

```bash
# On Kea server - create tarballs
tsh ssh --cluster=fuse.dsn.network root@dhcp-ct101 '
  cd /lib/x86_64-linux-gnu && \
  tar czf /tmp/kea-libs.tar.gz libkea-*.so.* liblog4cplus*.so.* && \
  tar czf /tmp/perfdhcp.tar.gz -C / usr/sbin/perfdhcp
'

# Copy to PVE host then push to test container
tsh ssh --cluster=fuse.dsn.network root@pv02 '
  scp root@10.205.0.20:/tmp/kea-libs.tar.gz /tmp/
  scp root@10.205.0.20:/tmp/perfdhcp.tar.gz /tmp/

  pct push 110 /tmp/kea-libs.tar.gz /tmp/kea-libs.tar.gz
  pct push 110 /tmp/perfdhcp.tar.gz /tmp/perfdhcp.tar.gz

  pct exec 110 -- tar xzf /tmp/kea-libs.tar.gz -C /lib/x86_64-linux-gnu/
  pct exec 110 -- tar xzf /tmp/perfdhcp.tar.gz -C /
  pct exec 110 -- ldconfig

  pct exec 110 -- /usr/sbin/perfdhcp -v
'
```

### 2. Run Load Tests

**Key flags:**
- `-4` - DHCPv4 mode
- `-r <rate>` - Target exchanges/second
- `-n <count>` - Total exchanges
- `-R <clients>` - Unique simulated clients
- `-l <iface>` - Network interface
- `-B` - **Broadcast mode (critical for LXC containers)**

**Baseline (100/sec):**
```bash
pct exec 110 -- /usr/sbin/perfdhcp -4 -r 100 -n 1000 -R 1000 -l eth1 -B
```

**Capacity (200/sec):**
```bash
pct exec 110 -- /usr/sbin/perfdhcp -4 -r 200 -n 1000 -R 1000 -l eth1 -B
```

**Stress (find max):**
```bash
pct exec 110 -- /usr/sbin/perfdhcp -4 -r 500 -n 2000 -R 2000 -l eth1 -B
```

### 3. Interpret Results

| Metric | Target | Concern |
|--------|--------|---------|
| Rate achieved | Match requested | <90% = bottleneck |
| DISCOVER-OFFER drops | <1% | >5% = server overload |
| REQUEST-ACK drops | <1% | >5% = DB bottleneck |
| Avg latency | <10ms | >50ms = stress |

**Healthy output:**
```
Rate: 199.5 4-way exchanges/second
DISCOVER-OFFER: drops ratio: 0.1 %, avg delay: 0.7 ms
REQUEST-ACK: drops ratio: 0.1 %, avg delay: 5.0 ms
```

**Overloaded output:**
```
Rate: 225 4-way exchanges/second, expected: 500
DISCOVER-OFFER: drops ratio: 20 %, avg delay: 70 ms
REQUEST-ACK: drops ratio: 43 %, avg delay: 75 ms
```

## Expected Results (PostgreSQL Backend)

| Rate | Expected |
|------|----------|
| 100/sec | Stable, <1% drops |
| 200/sec | Stable, ~1% drops (safe max) |
| 250/sec | ~230/sec achieved, 5-10% drops |
| 500/sec | ~230/sec achieved, 40%+ drops |

**PostgreSQL bottleneck:** ~230 leases/sec maximum

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| 0 responses | Wrong interface or missing -B | Use `-B` flag, verify interface on correct VLAN |
| Library errors | Missing Kea libs | Re-copy kea-libs.tar.gz, run ldconfig |
| Port 67 bind error | Running on DHCP server | Must run from separate container |

## Pre-Built Test Container

```bash
# Restore CT 110 with perfdhcp + dnsperf pre-installed
pct restore 110 pbs-dsn:backup/ct/110/2026-01-15T22:10:01Z --storage local-lvm --start 1

# Verify tools
pct exec 110 -- /usr/sbin/perfdhcp -v
pct exec 110 -- dnsperf -v
```
