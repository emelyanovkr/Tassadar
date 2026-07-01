# pxc

Prepares Ubuntu PXC nodes:

- installs packages required by the official Percona apt setup;
- installs and enables `percona-release`;
- enables the `pxc80` repository;
- installs Percona XtraDB Cluster packages;
- stops `mysql` and `mysql@bootstrap.service` before cluster configuration;
- renders `/etc/mysql/mysql.conf.d/mysqld.cnf` with cluster settings.

Host names must be `pxc-1`, `pxc-2`, and `pxc-3`.

Traffic encryption uses the PXC 8.0 default `pxc-encrypt-cluster-traffic`
behavior. The role does not manage custom SSL certificates yet.

The playbook bootstraps `pxc-1` after this role finishes. The role itself does
not start MySQL.
