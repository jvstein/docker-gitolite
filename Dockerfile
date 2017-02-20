FROM alpine:3.4

ENV GITOLITE_SRC https://github.com/sitaramc/gitolite.git

# Install dependencies and tweak the openssh config
# Create "git" user and group for ssh logins
RUN set -x \
 && apk add --no-cache git perl openssh \
 && sed -i -E -e "s|^#(HostKey.*/etc/ssh/)(ssh_host_.*_key)|\1keys/\2|" \
    -e "s/^#(PermitRootLogin|PasswordAuthentication|PrintMotd).*$/\1 no/" /etc/ssh/sshd_config \
 && addgroup -g 1000 git \
 && adduser -u 1000 -S -G git -s /bin/sh -h /var/lib/git git

# Volume used to store SSH host keys, generated on first run
VOLUME /etc/ssh/keys

# Volume used to store all Gitolite data (keys, config and repositories), initialized on first run
VOLUME /var/lib/git

# Install from the stable master branch
RUN git clone $GITOLITE_SRC /opt/gitolite \
 && /opt/gitolite/install -ln /usr/local/bin \
 && rm -rf /opt/gitolite/.git

# Entrypoint responsible for SSH host keys generation, and Gitolite data initialization
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# Expose port 22 to access SSH
EXPOSE 22

# Default command is to run the SSH server
CMD ["sshd"]
