#!/usr/bin/env bash
# Executed on the management VM via SSH stdin. Does not deploy or install anything.
set -euo pipefail

stage="cloud-init"
trap 'code=$?; printf "Manager check failed at %s (exit %s)\n" "$stage" "$code" >&2; exit "$code"' ERR

printf '[cloud-init] Waiting for successful initialization\n'
timeout 300 cloud-init status --wait

stage="bootstrap marker"
test -f /var/lib/tassadar/bootstrap-complete
printf '[bootstrap marker] Passed\n'

stage="OpenTofu"
tofu version

stage="Ansible"
ansible-playbook --version

stage="Git"
git --version

printf 'MANAGER_READINESS=ready\n'
