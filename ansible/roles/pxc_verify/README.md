# pxc_verify

Shared three-node PXC verification used by initial deployment and single-node
recovery. It requires pxc-1, pxc-2, and pxc-3 to be installed and running.

- Reads all nodes' wsrep status and requires size 3, Primary, Synced,
  connected ON, and ready ON.
- Creates the `percona` database and `percona.example` table if absent.
- Deletes existing rows in `percona.example` and writes one row from each node.
- Reads from every node, retrying until all three expected rows are present,
  then asserts exact equality of the returned records.

These tasks and their assertions were moved from `pxc_cluster` unchanged. The
recovery role's duplicate health checks were replaced by these equivalent
checks plus replication verification. No previous assertions were lost.

This role writes to the database. Reserve `percona.example` for verification
and do not run simultaneous checks against the same cluster.
