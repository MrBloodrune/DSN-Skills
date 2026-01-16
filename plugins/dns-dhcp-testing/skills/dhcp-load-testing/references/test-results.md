# DNS/DHCP Load Test Results Reference

**Cluster:** FUSE-CL01
**Date:** 2026-01-15

## Executive Summary

| Service | Max Capacity | Expected Load | Headroom |
|---------|--------------|---------------|----------|
| DNS (single server) | ~400K QPS | <5K QPS | 80x |
| DNS (combined) | ~805K QPS | <5K QPS | 160x |
| DHCP | ~200 leases/sec | <50/sec | 4x |

## DNS Load Test Results

### Target Servers

| Server | Container | IP | Software |
|--------|-----------|-----|----------|
| dns-ct101 | CT 102 | 10.205.2.11 | PowerDNS Recursor 5.3.3 |
| dns-ct102 | CT 103 | 10.205.2.12 | PowerDNS Recursor 5.3.3 |

### Single Server Results

| Target QPS | Achieved QPS | Queries | Success | Avg Latency |
|------------|--------------|---------|---------|-------------|
| 100 | 99.99 | 6,000 | 100% | 0.356ms |
| 1,000 | 999.99 | 60,000 | 100% | 0.092ms |
| 10,000 | 9,999.99 | 600,000 | 100% | 0.012ms |
| 50,000 | 49,999.94 | 2,999,998 | 100% | 0.015ms |
| **Unlimited** | **397,590** | **23,855,520** | **100%** | **0.248ms** |

### Combined Load Test

| Server | Achieved QPS | Queries | Success | Avg Latency |
|--------|--------------|---------|---------|-------------|
| dns-ct101 | 402,283 | 24,137,063 | 100% | 0.245ms |
| dns-ct102 | 402,898 | 24,173,951 | 100% | 0.216ms |
| **Combined** | **805,181** | **48,311,014** | **100%** | **0.230ms** |

## DHCP Load Test Results (perfdhcp)

### Target Server

| Server | Container | IP | Software |
|--------|-----------|-----|---------|
| dhcp-ct101 | CT 101 | 10.205.1.11 | Kea 2.6.4 + PostgreSQL 17 |

### Results

| Rate Target | Achieved | DISCOVER Drops | REQUEST Drops | DISCOVER Latency | REQUEST Latency | Status |
|-------------|----------|----------------|---------------|------------------|-----------------|--------|
| 100/sec | 99.5/sec | 0.5% | 0% | 1.5ms | 4.7ms | **PASS** |
| 200/sec | 197.6/sec | 0.5% | 0.5% | 1.2ms | 4.7ms | **PASS** |
| 250/sec | 192/sec | 16% | 8.3% | 40.8ms | 54.3ms | DEGRADED |
| 300/sec | 187/sec | 21.5% | 20.4% | 60.6ms | 74.5ms | OVERLOADED |

### Analysis

- **Safe capacity:** ~200 leases/sec
- **PostgreSQL bottleneck:** ~230 leases/sec sustained maximum
- **Production headroom:** 4x expected load

## Test Container Backup

```bash
# Pre-built container with perfdhcp + dnsperf
pct restore 110 pbs-dsn:backup/ct/110/2026-01-15T22:10:01Z --storage local-lvm
```
