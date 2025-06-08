#!/bin/bash
set -e

# Restore SQLite database from S3 if available
litestream restore -if-replica-exists -config /etc/litestream.yml /vaultwarden/data/db.sqlite3

# Start Litestream replication and Vaultwarden
exec litestream replicate -exec "/vaultwarden/vaultwarden" -config /etc/litestream.yml

