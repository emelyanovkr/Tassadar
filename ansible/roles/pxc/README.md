# pxc

Prepares Ubuntu PXC nodes:

- installs packages required by the official Percona apt setup;
- installs and enables `percona-release`;
- enables the `pxc80` repository;
- formats a new dedicated data disk as `ext4`;
- mounts the data disk at `/var/lib/mysql` using its stable by-id path;
- installs Percona XtraDB Cluster packages onto the mounted disk;
- renders `/etc/mysql/mysql.conf.d/mysqld.cnf` with cluster settings.

Host names must be `pxc-1`, `pxc-2`, and `pxc-3`.

Traffic encryption uses the PXC 8.0 default `pxc-encrypt-cluster-traffic`
behavior. The role does not manage custom SSL certificates yet.

The disk is mounted before package installation, so no existing MySQL data
directory needs to be copied. The role leaves MySQL stopped for bootstrap.
