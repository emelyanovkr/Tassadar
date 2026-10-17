# Infrastructure management rollout

## Agreed architecture

GitHub-hosted runners initiate operations and report their status in Actions.
They connect over SSH to the management VM, where OpenTofu and Ansible execute.
The public repository does not register the management VM as a persistent
self-hosted runner. Deployment operations will run from the default branch.

Bootstrap continues to create the VM using its own state. The main
infrastructure keeps its existing production state in Spaces.

## Stages and completion criteria

| Stage | Deliverable | Completion criterion |
| --- | --- | --- |
| 1. Manager connectivity | Manual Check management VM workflow | A GitHub run confirms SSH access, successful cloud-init, bootstrap marker, and working tools |
| 2. Execution environment | Repository checkout, temporary credentials, inventory paths valid on the VM | Manager can access the existing state and managed hosts |
| 3. Infrastructure plan | Main OpenTofu plan executed on the VM | Expected changes are reported without unexpected resource replacement |
| 4. Existing cluster verification | Shared Ansible health and write/read checks | Three healthy PXC nodes and replication checks pass |
| 5. Deployment operations | Separate infrastructure apply and initial PXC deployment operations | Requested operation completes with its required checks |
| 6. Recovery operations | Explicit target selection and optional outage test | Recovery completes and data checks pass |

Stage 1 code is available. Live verification from GitHub remains pending until
the workflow is published and its configuration below is added. Later stages
are planned. A successful manager check does not imply that the PXC cluster or
FlowerCA application has been deployed.

## Stage 1 configuration

Under repository Settings > Secrets and variables > Actions, add:

| Type | Name | Value |
| --- | --- | --- |
| Variable | MANAGER_HOST | Management VM public IPv4 or DNS name; currently 46.101.102.156 |
| Variable | MANAGER_SSH_KNOWN_HOSTS | Verified OpenSSH known_hosts entry for that exact host |
| Secret | MANAGER_SSH_PRIVATE_KEY | Complete matching private SSH key, usable without an interactive passphrase |

The current administrator identity in WSL is /home/kirill/.ssh/id_tassadar.
Only paste its contents into the GitHub Secret. Do not add the key to Git,
workflow YAML, logs, or chat. A .pub file is not a private key. A dedicated
automation identity can replace this administrator identity in a later stage.

For the host key, use an already trusted SSH connection and verify the
fingerprint against the DigitalOcean console when establishing initial trust.
In WSL, the following prints the full public known_hosts entry for the current VM:

    printf '46.101.102.156 '
    ssh -i /home/kirill/.ssh/id_tassadar -o IdentitiesOnly=yes \
      -o StrictHostKeyChecking=yes root@46.101.102.156 \
      "cut -d ' ' -f 1,2 /etc/ssh/ssh_host_ed25519_key.pub"

Paste the combined single line into MANAGER_SSH_KNOWN_HOSTS. It starts with
the host address followed by ssh-ed25519 and the public host key. This is
public metadata, not the administrator private key.

The workflow does not automatically trust a key from ssh-keyscan. A changed
host key must be verified before updating the variable. If bootstrap replaces
the VM, update its host address and verified known_hosts entry.

No DigitalOcean, Spaces, or MySQL credentials are required by this check.

## Run and results

Publish manager-check.yml and scripts/check-manager.sh to the default branch.
Choose Actions > Check management VM > Run workflow.

The workflow checks credentials and the pinned host key, connects as root,
and executes the repository's readiness script on the VM over SSH stdin.
It does not install software or change infrastructure. A timeout, failed SSH
authentication, changed host key, failed cloud-init, missing bootstrap marker,
or failing tool command fails the job.

The Summary always reports the SSH configuration and readiness step outcomes.
Only a successful readiness step reports Manager: READY. Failure or skipped
readiness reports NOT VERIFIED. Logs identify the remote check that failed.
Temporary private key and known_hosts files are removed in the cleanup step.
Neither credentials nor state/plan files are uploaded as artifacts.

## Subsequent operations

The first infrastructure run will be a plan against the existing production
state, followed by verification of the existing cluster. Initial PXC bootstrap
must not be automatically repeated on a running cluster. Recovery and the
deliberate outage test remain separate, explicitly selected operations.

The workflow status records the result of a particular run. Continuous
monitoring of deployed services is a later stage.
