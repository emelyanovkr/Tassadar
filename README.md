# FiddInfra

## Setup
1. Get an authorized key json file for the service account and save it outside the repository.
2. Create `.env`
3. Fill `.env`:

```bash
export YC_CLOUD_ID="<cloud-id>"
export YC_FOLDER_ID="<folder-id>"
export YC_ZONE="ru-central1-a"
export YC_SERVICE_ACCOUNT_KEY_FILE="$HOME/.config/yandex-cloud/authorized_key.json"
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
