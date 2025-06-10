#!/bin/bash
set -e

# AWS Lambda runtime requires initialization
echo "Starting Vaultwarden Lambda container..."

# Ensure required directories exist
mkdir -p /tmp/vaultwarden/data

# Restore SQLite database from S3 if available
litestream restore -if-replica-exists /tmp/vaultwarden/data/db.sqlite3

# Start Litestream in background for continuous replication
litestream replicate -config /etc/litestream.yml &

# Sanitiy check
pwd
ls -la
ls ./web-vault -la

# Start Vaultwarden
exec /vaultwarden/vaultwarden


