# DSN Skills Marketplace

Claude Code plugin marketplace for DSN managed services infrastructure operations.

## Overview

This marketplace provides independently installable plugins for DSN managed services operations:

| Plugin | Description | Triggers |
|--------|-------------|----------|
| [backup-recovery](plugins/backup-recovery) | PBS backup, restore, disaster recovery | "backup a VM", "restore container", "list backups" |
| [proxmox-operations](plugins/proxmox-operations) | General PVE cluster operations | "manage VMs", "cluster status", "migrate" |
| [dns-dhcp-testing](plugins/dns-dhcp-testing) | DNS/DHCP load testing with real examples | "load test DHCP", "run dnsperf" |
| [fortigate-admin](plugins/fortigate-admin) | FortiGate firewall administration | "check firewall", "add policy", "VPN tunnel" |

## Installation

### Install Specific Plugin

```bash
# Clone marketplace
git clone git@github.com:MrBloodrune/DSN-Skills.git

# Install specific plugin (symlink to Claude Code plugins)
ln -s ~/DSN-Skills/plugins/backup-recovery ~/.claude/plugins/backup-recovery

# Or copy
cp -r ~/DSN-Skills/plugins/backup-recovery ~/.claude/plugins/
```

### Install All Plugins

```bash
# Install all plugins
for plugin in ~/DSN-Skills/plugins/*/; do
  ln -s "$plugin" ~/.claude/plugins/$(basename "$plugin")
done
```

## Marketplace Structure

```
DSN-Skills/
├── .claude-plugin/
│   └── marketplace.json          # Plugin registry/catalog
├── plugins/
│   ├── backup-recovery/          # PBS backup/restore operations
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   │       └── backup-recovery/
│   │           ├── SKILL.md
│   │           ├── references/
│   │           ├── examples/
│   │           └── scripts/
│   ├── proxmox-operations/       # General PVE operations
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── skills/
│   └── dns-dhcp-testing/         # Load testing
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── skills/
└── README.md
```

## Supported Infrastructure

### PBS Server

| Property | Value |
|----------|-------|
| Server | LTRKAR02-PBS01 |
| Address | 10.101.1.250:8007 |
| Datastore | HDD-BACKUP (32.7 TB) |

### Connected Clusters

| Cluster | Namespace | Purpose |
|---------|-----------|---------|
| LTRKAR02-CL01 | DSN | DSN core services |
| FUSE-CL01 | Fuse | Managed customer |

## Plugin Details

### backup-recovery

Comprehensive PBS operations with real-world examples captured from production:

- Manual VM/CT backup procedures
- Restore operations (new VMID, force overwrite)
- Host configuration backup/restore
- Scheduled backup job management
- Troubleshooting guides

**Real output captured:**
```
INFO: virtio0: dirty-bitmap status: OK (628.0 MiB of 60.0 GiB dirty)
INFO: backup was done incrementally, reused 59.39 GiB (98%)
INFO: transferred 628.00 MiB in 4 seconds (157.0 MiB/s)
```

### proxmox-operations

Quick reference for common Proxmox VE operations:

- Cluster health checks
- VM/CT lifecycle management
- Migration procedures
- Resource monitoring
- Ceph status (if applicable)

### dns-dhcp-testing

Load testing procedures with actual results from FUSE-CL01:

- dnsperf for DNS (achieved 805K QPS combined)
- perfdhcp for DHCP (found ~200/sec safe limit)
- Pre-built test container backup available
- LXC-specific workarounds documented

### fortigate-admin

Comprehensive FortiGate firewall administration:

- Policy management (create, modify, append)
- Address objects and groups
- VPN/IPsec tunnel operations
- Routing and diagnostics
- Scripted SSH command patterns
- Environment-specific configs (LTRKAR02-DF04, HMBGAR01-DF01/DF02)

**Includes:**
- Complete CLI command reference
- VPN troubleshooting procedures
- Debug traffic flow examples
- Session debugging workflows

## Usage Examples

```
User: Backup VM 1001 on LTRKAR02
Claude: [Uses backup-recovery skill with correct storage ID and notes template]

User: How do I restore container 101 on FUSE?
Claude: [Provides pct restore command with pbs-dsn storage]

User: Load test the DHCP server
Claude: [Uses dns-dhcp-testing skill with perfdhcp procedures]

User: Check the VPN tunnel to DSN
Claude: [Uses fortigate-admin skill with tunnel diagnostics]

User: Add address object for new server
Claude: [Uses fortigate-admin skill with proper scripted SSH pattern]
```

## Contributing

1. Fork the repository
2. Create a new plugin in `plugins/<plugin-name>/`
3. Follow the structure pattern from existing plugins
4. Update `marketplace.json` with new plugin entry
5. Submit a pull request

## License

MIT License

## Author

DSN Network - admin@dsn.network
