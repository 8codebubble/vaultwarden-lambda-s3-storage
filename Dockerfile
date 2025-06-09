# Use Amazon Linux 2 base image (supports `yum`)
FROM amazonlinux:2

# Set the default value for the data directory to a writable location
ENV VAULTWARDEN_DATA_DIR="/tmp/vaultwarden/data"

# Install dependencies using yum
RUN yum install -y tar sqlite curl ca-certificates jq unzip && yum clean all

# Use the GitHub API to get the download URL for the latest release asset
# that ends with "litestream-linux-amd64.zip".
RUN export LATEST_ASSET_URL=$(curl -s "https://api.github.com/repos/benbjohnson/lightstream/releases/latest" | \
      jq -r '.assets[] | select(.name | endswith("linux-amd64.zip")) | .browser_download_url') && \
    echo "Downloading Litestream from: ${LATEST_ASSET_URL}" && \
    # Download the zip asset to /tmp
    curl -L "${LATEST_ASSET_URL}" -o /tmp/litestream.zip && \
    # Unzip the asset into /usr/local/bin. Adjust the extracted file path if necessary.
    unzip /tmp/litestream.zip -d /usr/local/bin/ && \
    # Rename the extracted binary to "litestream" (adjust if the zip preserves directory structure)
    mv /usr/local/bin/litestream-linux-amd64 /usr/local/bin/litestream && \
    chmod +x /usr/local/bin/litestream && \
    rm /tmp/litestream.zip

# Optionally, verify installation by printing the version
RUN litestream --version

# Set working directory
WORKDIR /vaultwarden

# Copy Vaultwarden binary from latest release
COPY vaultwarden /vaultwarden/vaultwarden

# Copy Litestream config
COPY litestream.yml /etc/litestream.yml

# Expose Vaultwarden API port
EXPOSE 8080

# AWS Lambda requires entrypoint to be `/lambda-entrypoint.sh`
COPY lambda-entrypoint.sh /lambda-entrypoint.sh
RUN chmod +x /lambda-entrypoint.sh

# CMD for AWS Lambda container execution
CMD ["/lambda-entrypoint.sh"]
