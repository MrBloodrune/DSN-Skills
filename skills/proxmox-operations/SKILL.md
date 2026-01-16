---
name: Proxmox Operations
description: General Proxmox VE cluster operations. Use when asked to "manage VMs", "check cluster status", "migrate containers", "view node resources", or perform Proxmox administration tasks.
version: 1.0.0
---

# Proxmox VE Operations

Quick reference for common Proxmox cluster operations.

## Cluster Status

### Check Cluster Health

```bash
# Cluster status
pvecm status

# HA status
ha-manager status

# Node status
pvecm nodes
```

### Storage Status

```bash
# List all storage
pvesm status

# Storage usage
pvesm list <storage-id>

# Check specific storage
df -h /mnt/pve/<storage-name>
```

## VM Operations

### Basic VM Commands

```bash
# List VMs
qm list

# VM status
qm status <vmid>

# Start/Stop/Restart
qm start <vmid>
qm stop <vmid>
qm shutdown <vmid>
qm reboot <vmid>

# VM configuration
qm config <vmid>
```

### VM Migration

```bash
# Online migration
qm migrate <vmid> <target-node>

# Offline migration
qm migrate <vmid> <target-node> --offline
```

## Container Operations

### Basic CT Commands

```bash
# List containers
pct list

# Container status
pct status <ctid>

# Start/Stop/Restart
pct start <ctid>
pct stop <ctid>
pct shutdown <ctid>
pct reboot <ctid>

# Container configuration
pct config <ctid>

# Enter container
pct enter <ctid>

# Execute command in container
pct exec <ctid> -- <command>
```

### Container Migration

```bash
# Online migration
pct migrate <ctid> <target-node>

# Offline migration (for local storage)
pct migrate <ctid> <target-node> --restart
```

## Resource Monitoring

### Node Resources

```bash
# CPU and memory
pvesh get /nodes/<node>/status

# Top processes
top -bn1 | head -20

# Memory details
free -h

# Disk I/O
iostat -x 1 5
```

### Ceph Status (if applicable)

```bash
# Ceph health
ceph -s

# OSD status
ceph osd tree

# Pool status
ceph df
```

## Task Management

### View Tasks

```bash
# Recent tasks
pvesh get /nodes/<node>/tasks --limit 10

# Task by type
pvesh get /nodes/<node>/tasks --typefilter vzdump

# Task status
pvesh get /nodes/<node>/tasks/<upid>/status
```

## Network

### Check Network

```bash
# Network interfaces
ip addr show

# Bridge status
brctl show

# VLAN interfaces
cat /etc/network/interfaces
```

## Logs

### Important Log Files

```bash
# System log
journalctl -xe

# Proxmox tasks
journalctl -u pvedaemon

# Storage
journalctl -u pvestatd

# HA
journalctl -u pve-ha-crm
```

## Quick Diagnostics

### Full System Check

```bash
# Cluster
pvecm status

# Storage
pvesm status

# HA
ha-manager status

# Ceph (if applicable)
ceph -s

# Recent tasks
pvesh get /nodes/$(hostname)/tasks --limit 5
```
