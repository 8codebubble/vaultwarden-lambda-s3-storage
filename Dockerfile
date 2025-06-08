# Use an AWS Lambda-compatible base image
FROM public.ecr.aws/lambda/provided:latest

# Install dependencies manually (since microdnf isn't available)
RUN curl -L https://github.com/sqlite/sqlite/releases/latest/download/sqlite3 \
    -o /usr/local/bin/sqlite3 && chmod +x /usr/local/bin/sqlite3 && \
    curl -L https://curl.se/download/curl-linux-x86_64.tar.gz | tar -xz -C /usr/local/bin && \
    ln -s /usr/local/bin/curl /usr/bin/curl

# tar is missing on this image
RUN curl -L https://github.com/sqlite/sqlite/releases/latest/download/sqlite3 \
    -o /usr/local/bin/sqlite3 && chmod +x /usr/local/bin/sqlite3 && \
    yum install -y tar && \
    curl -L https://curl.se/download/curl-linux-x86_64.tar.gz | tar -xz -C /usr/local/bin && \
    ln -s /usr/local/bin/curl /usr/bin/curl

# Install Litestream for SQLite replication
RUN curl -L https://github.com/benbjohnson/litestream/releases/latest/download/litestream-linux-amd64 \
    -o /usr/local/bin/litestream && chmod +x /usr/local/bin/litestream

# Install Litestream for SQLite replication
RUN curl -L https://github.com/benbjohnson/litestream/releases/latest/download/litestream-linux-amd64 \
    -o /usr/local/bin/litestream && chmod +x /usr/local/bin/litestream

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
