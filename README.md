# Tassadar infrastructure

OpenTofu provisions a three-node Percona XtraDB Cluster in DigitalOcean. Ansible installs and bootstraps PXC 8.0 on the created Droplets.

## Architecture

- the region's default DigitalOcean VPC, reused and kept after `tofu destroy`;
- one public bastion Droplet;
- three PXC Droplets connected through private VPC addresses;
- one dedicated ext4 Block Storage volume per PXC node;
- Cloud Firewalls allowing SSH/MySQL from the bastion and Galera traffic only between PXC nodes.

## Configuration

1. Create the local OpenTofu variables file:

```bash
cp tofu/secrets.auto.tfvars.example tofu/secrets.auto.tfvars
```

Edit `tofu/secrets.auto.tfvars` and replace the placeholders. OpenTofu loads this file automatically.

2. Store the DigitalOcean Spaces credentials in the standard AWS credentials file:

```bash
mkdir -p ~/.aws
chmod 700 ~/.aws
```

Create or update `~/.aws/credentials`:

```ini
[tassadar-spaces]
aws_access_key_id = <spaces-access-key-id>
aws_secret_access_key = <spaces-secret-access-key>
```

Protect the credentials file:

```bash
chmod 600 ~/.aws/credentials
```

Neither local file should be committed. `project_id` can be set to `null` to keep resources in the DigitalOcean default project.

## OpenTofu

Run from `tofu/`:

```bash
tofu init -reconfigure
tofu fmt -recursive
tofu validate
tofu plan
tofu apply
```

OpenTofu stores remote state in the private `tassadar-s3` DigitalOcean Spaces bucket at `tassadar/production.tfstate`. The backend reads Spaces credentials from the `tassadar-spaces` profile in `~/.aws/credentials`.

OpenTofu generates `ansible/inventory.ini`. The PXC hosts are reached by their private VPC addresses through the bastion.

## Ansible

Run from `ansible/`:

```bash
ansible bastion -m ping
ansible pxc -m ping
ansible-playbook playbooks/pxc.yml
```

The playbook:

1. installs Percona XtraDB Cluster 8.0;
2. mounts each DigitalOcean volume at `/var/lib/mysql`;
3. bootstraps `pxc-1`;
4. joins `pxc-2` and `pxc-3`;
5. verifies cluster health and replication.

Generated MySQL passwords stay in `ansible/.generated/` and must not be committed.

Useful checks:

```bash
ansible-playbook playbooks/pxc.yml --tags verify

ansible pxc -b -m shell -a \
  "MYSQL_PWD='$(cat .generated/pxc_root_password)' mysql --user=root --batch --skip-column-names --execute=\"SHOW STATUS LIKE 'wsrep_cluster_size';\""
```

The expected cluster size is `3` on every PXC node.
