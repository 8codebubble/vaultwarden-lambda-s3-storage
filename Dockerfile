# Use Amazon Linux 2 base image (supports `yum`)
FROM amazonlinux:2

# Set the default value for the data directory to a writable location
ENV VAULTWARDEN_DATA_DIR="/tmp/vaultwarden/data"

# Install dependencies using yum
RUN yum install -y tar sqlite curl ca-certificates jq unzip && yum clean all

# Use the GitHub API to get the download URL for the latest release asset
# that ends with "litestream-linux-amd64.zip".
RUN export LATEST_ASSET_URL=$(curl -s "https://api.github.com/repos/benbjohnson/litestream/releases/latest" | \
      jq -r '.assets[] | select(.name | endswith("linux-amd64.tar.gz")) | .browser_download_url') && \
    echo "Downloading Litestream asset from: ${LATEST_ASSET_URL}" && \
    curl -L "${LATEST_ASSET_URL}" -o /tmp/litestream.tar.gz && \
    # Extract the tar.gz archive; assuming it contains a file named litestream-linux-amd64
    tar -xzvf /tmp/litestream.tar.gz -C /usr/local/bin/ && \
    # Rename the binary to "litestream" if needed. Adjust the source name if the archive structure differs.
    mv /usr/local/bin/litestream-linux-amd64 /usr/local/bin/litestream && \
    chmod +x /usr/local/bin/litestream && \
    rm /tmp/litestream.tar.gz

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
