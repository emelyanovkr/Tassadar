# playbooks/pxc.yml

Installs and bootstraps Percona XtraDB Cluster on three private nodes.

The playbook runs in two main steps:

1. `pxc` installs Percona packages and renders MySQL/PXC configuration.
2. `pxc_cluster` bootstraps the first node, joins the remaining nodes, and runs health/replication checks.

What it does:

- installs official Percona apt prerequisites;
- installs `percona-release`;
- enables the `pxc80` repository;
- installs `percona-xtradb-cluster`;
- renders PXC cluster configuration on all three nodes;
- bootstraps only `pxc-1` with `mysql@bootstrap.service`;
- verifies that `pxc-1` is a healthy single-node Primary cluster;
- copies PXC TLS files from `pxc-1` to joiner nodes;
- joins `pxc-2` and verifies a healthy 2-node Primary cluster;
- joins `pxc-3` and verifies a healthy 3-node Primary cluster;
- verifies wsrep health on every node;
- verifies replication by creating a database/table/row across different nodes.

Run from the `ansible` directory:

```bash
ansible-playbook playbooks/pxc.yml
```

Useful tags:

```bash
ansible-playbook playbooks/pxc.yml --tags install
ansible-playbook playbooks/pxc.yml --tags cluster
ansible-playbook playbooks/pxc.yml --tags verify
```

## Connectivity

The PXC nodes do not have public IP addresses. Ansible connects to them through
the bastion host using the generated `inventory.ini`.

Basic SSH checks:

```bash
ansible -i inventory.ini bastion -m ping
ansible -i inventory.ini pxc -m ping
```

## MySQL checks

The root password is generated locally in `.generated/pxc_root_password`.

Read wsrep status from the first node:

```bash
ansible -i inventory.ini pxc-1 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"SHOW STATUS LIKE 'wsrep%';\""
```

Check cluster size on all nodes:

```bash
ansible -i inventory.ini pxc -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --batch --skip-column-names --execute=\"SHOW STATUS LIKE 'wsrep_cluster_size';\""
```

Useful manual replication test:

```bash
ansible -i inventory.ini pxc-2 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"CREATE DATABASE IF NOT EXISTS percona_manual;\""

ansible -i inventory.ini pxc-3 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"CREATE TABLE IF NOT EXISTS percona_manual.example (id INT PRIMARY KEY, node_name VARCHAR(30));\""

ansible -i inventory.ini pxc-1 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"INSERT INTO percona_manual.example VALUES (1, 'pxc-1') ON DUPLICATE KEY UPDATE node_name = VALUES(node_name);\""

ansible -i inventory.ini pxc-2 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"SELECT * FROM percona_manual.example;\""
```
