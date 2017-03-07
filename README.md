# Docker image for Gitolite

This image allows you to run an OpenSSH server in a container with OpenSSH, [gitolite](https://github.com/sitaramc/gitolite#readme) and [git-notifier](https://github.com/rsmmr/git-notifier#readme).

Based on Alpine Linux.

## Quick Start
Run gitolite on port 10022, using the current user's RSA key as the new admin,
with the data stored in `/path/to/data` and the host ssh keys stored in
`/path/to/keys`.

    docker run -d --name gitolite \
      -v /path/to/keys:/etc/ssh/keys \
      -v /path/to/data:/var/lib/gitolite \
      -p 10022:22 \
      -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" \
      -e SSH_KEY_NAME="$(whoami)" \
      jvstein/gitolite

You can then add users and repos by following the [official guide](https://github.com/sitaramc/gitolite#adding-users-and-repos).

    git clone ssh://git@localhost:10022/gitolite-admin
