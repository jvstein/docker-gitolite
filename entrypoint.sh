#!/bin/sh

# if command is sshd, set it up correctly
if [ "${1}" = 'sshd' ]; then
  # non-daemon mode, logging to stderr
  set -- /usr/sbin/sshd -De

  # Setup SSH HostKeys if needed
  for algorithm in rsa dsa ecdsa ed25519
  do
    keyfile=/etc/ssh/keys/ssh_host_${algorithm}_key
    [ -f $keyfile ] || ssh-keygen -q -N '' -f $keyfile -t $algorithm
  done
fi
 
# Setup gitolite admin  
if [ ! -f ~git/.ssh/authorized_keys ]; then
  if [ -n "$SSH_KEY" ]; then
    [ -n "$SSH_KEY_NAME" ] || SSH_KEY_NAME=admin
    echo "$SSH_KEY" > "/tmp/$SSH_KEY_NAME.pub"
    su - git -c "gitolite setup -pk \"/tmp/$SSH_KEY_NAME.pub\""
    rm "/tmp/$SSH_KEY_NAME.pub"
  else
    echo "You need to specify SSH_KEY on first run to setup gitolite"
    echo "You can also use SSH_KEY_NAME to specify the key name (optional)"
    echo 'Example: docker run -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" jvstein/gitolite'
    exit 1
  fi
fi

# Check setup at every startup
su - git -c "gitolite setup"

exec "$@"
