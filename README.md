# FiddInfra

## Setup
1. Get an authorized key json file for the service account and save it outside the repository.
2. Create `.env`
3. Fill `.env`:

```bash
export YC_CLOUD_ID="<cloud-id>"
export YC_FOLDER_ID="<folder-id>"
export YC_ZONE="ru-central1-a"
# Create this key in Identity and Access Management > Service Accounts.
export YC_SERVICE_ACCOUNT_KEY_FILE="$HOME/.config/yandex-cloud/authorized_key.json"
# Add the matching private key to ssh-agent before running Ansible.
export TF_VAR_ssh_public_key_path="$HOME/.ssh/id_tassadar.pub"
```

! Alternatively, add these variables to `~/.zshrc` or `~/.bashrc`. They will be loaded automatically for every new terminal session.

4. Load env:

```bash
source .env
```

## Commands

Run commands from the `tofu` directory:

```bash
cd tofu
```

- `tofu init` initializes the working directory and downloads providers.
- `tofu fmt -recursive` formats all OpenTofu files.
- `tofu validate` checks the configuration syntax and internal consistency.
- `tofu plan` shows which infrastructure changes will be made.
- `tofu apply` applies the planned infrastructure changes.
- `tofu destroy` deletes all infrastructure managed by the current state.

## Ansible

OpenTofu generates the Ansible inventory at `ansible/inventory.ini`.
The bastion host has a public IP address, while the PXC nodes have only private
addresses. Connections to `pxc-1`, `pxc-2`, and `pxc-3` therefore go through
the bastion according to the SSH options in the generated inventory.

Run commands from the `ansible` directory:

```bash
cd ansible
```

Check SSH access:

```bash
ansible bastion -m ping
ansible pxc -m ping
```

Install Percona and configure the three-node cluster:

```bash
ansible-playbook playbooks/pxc.yml
```

The playbook runs in two stages:

1. The `pxc` role installs Percona XtraDB Cluster, formats each empty dedicated
   data disk, mounts it at `/var/lib/mysql`, and writes the MySQL/PXC
   configuration on all three nodes.
2. The `pxc_cluster` role bootstraps `pxc-1`, joins `pxc-2` and `pxc-3` one at
   a time, and verifies cluster health and replication.

The playbook generates the MySQL root password on first run and stores it in
`ansible/.generated/`, which is ignored by git. To use your own password,
override `pxc_root_password_override` in Ansible vars.

Run only a particular part of the playbook when needed:

```bash
ansible-playbook playbooks/pxc.yml --tags install
ansible-playbook playbooks/pxc.yml --tags cluster
ansible-playbook playbooks/pxc.yml --tags verify
```

The `install` stage leaves MySQL stopped so that the cluster can be bootstrapped
safely. Run the full playbook for the initial deployment. Use `cluster` after
the nodes are prepared and `verify` only for an already running cluster.

Check wsrep status on the first node:

```bash
ansible pxc-1 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"SHOW STATUS LIKE 'wsrep%';\""
```

Check the cluster size on every node:

```bash
ansible pxc -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --batch --skip-column-names --execute=\"SHOW STATUS LIKE 'wsrep_cluster_size';\""
```

The expected value is `3` on every PXC node. See `ansible/README.md` for the
detailed playbook flow and role variables.

Run a basic SQL query on `pxc-1`:

```bash
ansible pxc-1 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"SELECT VERSION(); SHOW DATABASES;\""
```

To test replication manually, write on one node and read on another:

```bash
ansible pxc-1 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"CREATE DATABASE IF NOT EXISTS pxc_test; CREATE TABLE IF NOT EXISTS pxc_test.example (id INT PRIMARY KEY, value VARCHAR(30)); INSERT INTO pxc_test.example VALUES (1, 'from-pxc-1') ON DUPLICATE KEY UPDATE value = VALUES(value);\""

ansible pxc-2 -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --execute=\"SELECT * FROM pxc_test.example;\""
```
