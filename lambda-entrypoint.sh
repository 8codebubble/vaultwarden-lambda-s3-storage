#!/bin/bash
set -e

# AWS Lambda runtime requires initialization
echo "Starting Vaultwarden Lambda container..."

# Create the directory (if necessary) so that it's available when the container starts.
echo $VAULTWARDEN_DATA_DIR
echo ${VAULTWARDEN_DATA_DIR}
mkdir ${VAULTWARDEN_DATA_DIR}

# Restore SQLite database from S3 if available
litestream restore -if-replica-exists ${VAULTWARDEN_DATA_DIR}/db.sqlite3

# Start Litestream in background for continuous replication
litestream replicate -config /etc/litestream.yml &

# Start Vaultwarden
exec /vaultwarden/vaultwarden


