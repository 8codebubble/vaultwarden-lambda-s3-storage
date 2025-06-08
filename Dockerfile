# Use an AWS Lambda-compatible base image
FROM public.ecr.aws/lambda/provided:latest

# Install dependencies manually (since no package manager exists)
RUN curl -L https://ftp.gnu.org/gnu/tar/tar-latest.tar.gz -o tar-latest.tar.gz && \
    mkdir tar-install && cd tar-install && \
    gzip -d ../tar-latest.tar.gz && \
    tar -xvf ../tar-latest.tar && \
    ./configure && make && make install

# Install SQLite manually
RUN curl -L https://sqlite.org/2024/sqlite-tools-linux-x86_64.tar.gz -o sqlite.tar.gz && \
    tar -xzf sqlite.tar.gz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/sqlite3 && rm sqlite.tar.gz

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
