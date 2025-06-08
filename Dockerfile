FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    sqlite3 \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Litestream for SQLite replication
RUN curl -L https://github.com/benbjohnson/litestream/releases/latest/download/litestream-linux-amd64 \
    -o /usr/local/bin/litestream && chmod +x /usr/local/bin/litestream

# Set working directory
WORKDIR /vaultwarden

# Copy Vaultwarden binary from latest release
COPY vaultwarden /vaultwarden/vaultwarden

# Copy Litestream config
COPY litestream.yml /etc/litestream.yml

# Define entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Vaultwarden API port
EXPOSE 8080

# Start Vaultwarden with Litestream replication
CMD ["/entrypoint.sh"]

