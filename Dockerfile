FROM alpine:3.4

ENV GITOLITE_SRC https://github.com/sitaramc/gitolite.git

# Install dependencies and tweak the openssh config
# Create user and group with same ids as the gitolite package
RUN set -x \
 && apk add --no-cache git perl openssh \
 && sed -i -E -e "s|^#(HostKey.*/etc/ssh/)(ssh_host_.*_key)|\1keys/\2|" \
    -e "s/^#(PermitRootLogin|PasswordAuthentication|PrintMotd).*$/\1 no/" /etc/ssh/sshd_config \
 && addgroup -g 101 git \
 && adduser -u 100 -D -G git -s /bin/sh -h /var/lib/git git \
 && passwd -u git

# Volume used to store SSH host keys, generated on first run
VOLUME /etc/ssh/keys

# Volume used to store all Gitolite data (keys, config and repositories), initialized on first run
VOLUME /var/lib/git

# Install from the stable master branch
RUN git clone $GITOLITE_SRC /opt/gitolite \
 && /opt/gitolite/install -ln /usr/local/bin \
 && rm -rf /opt/gitolite/.git

# Entrypoint responsible for SSH host keys generation, and Gitolite data initialization
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

# Expose port 22 to access SSH
EXPOSE 22

# Default command is to run the SSH server
CMD ["sshd"]
