# playbooks/pxc.yml

This playbook installs and configures a three-node Percona XtraDB Cluster. It
expects the inventory group `pxc` to contain exactly `pxc-1`, `pxc-2`, and
`pxc-3`.

The playbook consists of two plays and two roles:

1. `Prepare Percona nodes` runs the `pxc` role on all PXC nodes.
2. `Configure PXC cluster` runs the `pxc_cluster` orchestration role.

## Role `pxc`

The preparation role performs the same installation and configuration steps on
all three nodes:

- validates Ubuntu, the inventory host names, and the generated root password;
- waits until `cloud-init` has finished;
- installs the packages required by the official Percona apt repository;
- installs `percona-release` and enables the `pxc80` repository;
- waits for the dedicated data device at `/dev/disk/by-id/virtio-data`;
- formats the device as `ext4` only when it does not already contain a
  filesystem;
- persists the stable `/dev/disk/by-id/virtio-data` mount in `/etc/fstab`;
- preseeds the MySQL root password for non-interactive package installation;
- installs the `percona-xtradb-cluster` package directly onto the mounted data
  disk without automatically starting MySQL;
- calculates `server_id` from the inventory name (`pxc-1` becomes `1`);
- renders `/etc/mysql/mysql.conf.d/mysqld.cnf` from
  `roles/pxc/templates/pxc.cnf.j2`.

The disk is mounted before the Percona package is installed, so MySQL creates
its data directory on the dedicated disk from the beginning. There is no
datadir migration or copy step. A disk with an unexpected filesystem causes
the role to fail instead of formatting it.

The rendered configuration contains the Galera provider, cluster name and
address, node name and private address, strict mode, SST method, and the MySQL
settings required by PXC. `wsrep_cluster_address` is built automatically from
the private `ansible_host` values of every host in the `pxc` group.

## Role `pxc_cluster`

The cluster role orchestrates the nodes in a strict order:

1. Starts `mysql@bootstrap.service` only on `pxc-1`.
2. Waits until `pxc-1` reports a one-node `Primary` cluster in the `Synced`
   state with `wsrep_connected=ON` and `wsrep_ready=ON`.
3. Reads the default PXC TLS files from `pxc-1` and copies them to each joining
   node.
4. Starts regular `mysql` on `pxc-2` and verifies a healthy two-node cluster.
5. Starts regular `mysql` on `pxc-3` and verifies a healthy three-node
   cluster.
6. Checks wsrep health on every node.
7. Verifies replication with a database, table, and row written across
   different nodes.

The orchestration tasks use `run_once` with `delegate_to`. Ansible still opens
each SSH connection from the local control machine through the bastion; the PXC
nodes do not connect to each other over SSH.

## Variables

Cluster variables are defined in `group_vars/pxc.yml`:

- `pxc_repo` selects the Percona repository (`pxc80` by default);
- `pxc_cluster_name` sets the wsrep cluster name;
- `pxc_provider` points to the Galera provider library;
- `pxc_sst_method` selects the state snapshot transfer method;
- `pxc_mysql_datadir` points to the MySQL data directory;
- `pxc_data_device` and `pxc_data_filesystem` control the dedicated
  data-disk mount;
- `pxc_tls_files` and `pxc_tls_private_files` describe the TLS files copied
  from the bootstrap node;
- `pxc_cluster_address` is generated from all PXC private IP addresses;
- `pxc_root_password` is generated once in `.generated/pxc_root_password`.

To provide a fixed root password, define `pxc_root_password_override` in
Ansible variables. Do not commit the password to the repository.

## Tags

- `install` runs package installation and configuration;
- `cluster` runs bootstrap and sequential node joins;
- `verify` runs wsrep health and replication checks.

The initial deployment should use the complete playbook. The `install` tag
prepares storage and leaves MySQL stopped, `cluster` expects prepared nodes,
and `verify` expects an already running three-node cluster.

Project-level run commands, connectivity checks, and basic MySQL commands are
documented in the root `README.md`.
