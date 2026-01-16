# Cluster Configuration Reference

## PBS Server

| Property | Value |
|----------|-------|
| Hostname | LTRKAR02-PBS01 |
| IP | 10.101.1.250 |
| Web UI | https://10.101.1.250:8007 |
| Datastore | HDD-BACKUP |
| Capacity | 32.7 TB (RAID-10) |
| Fingerprint | `1d:f6:06:b2:b7:8b:6e:74:1c:c5:17:56:89:b7:d2:dd:9e:c2:e8:33:8f:03:01:57:63:19:71:f2:0f:02:fe:66` |

### Hardware Constraints

- RAID Controller: PERC H330 (no write cache)
- Max throughput: ~100 MB/s sustained
- Recommendation: Use `--bwlimit 102400` for VMs >500GB

## LTRKAR02-CL01 (DSN Core)

| Property | Value |
|----------|-------|
| Storage ID | PBS-DSN |
| Namespace | DSN |
| User | dsn-backup@pam |
| Network | L2 direct (VLAN 101) |
| Job ID | daily-vm-backup |
| Schedule | 02:00 daily |

### Nodes

| Node | IP |
|------|-----|
| LTRKAR02-PV01 | 10.101.1.11 |
| LTRKAR02-PV02 | 10.101.1.12 |
| LTRKAR02-PV03 | 10.101.1.13 |
| LTRKAR02-PV04 | 10.101.1.14 |

## FUSE-CL01 (Managed Customer)

| Property | Value |
|----------|-------|
| Storage ID | pbs-dsn |
| Namespace | Fuse |
| User | fuse-backup@pam |
| Network | FuseRural IPsec tunnel |
| Job ID | fuse-daily |
| Schedule | 02:00 daily |

### Nodes

| Node | IP |
|------|-----|
| pv01 | 10.205.0.11 |
| pv02 | 10.205.0.12 |
| pv03 | 10.205.0.13 |
| pv04 | 10.205.0.14 |

## Retention Policy (All Clusters)

| keep-last | keep-daily | keep-weekly | keep-monthly | keep-yearly |
|-----------|------------|-------------|--------------|-------------|
| 3 | 7 | 4 | 6 | 1 |
