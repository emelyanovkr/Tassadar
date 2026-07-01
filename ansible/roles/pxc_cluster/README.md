# pxc_cluster

Orchestrates an already installed Percona XtraDB Cluster from one play:

- bootstraps `pxc-1`;
- reads PXC TLS files from `pxc-1`;
- joins the remaining nodes one by one;
- verifies wsrep health;
- verifies replication with a small database/table/row test.
