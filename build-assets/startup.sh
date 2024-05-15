#!/bin/bash -e

if [ $(id -u) -gt 0 ]; then
  echo "Must run as root! Aborting..."
  exit 1
fi

if [ -z $WORKSPACE_USER ] || [ -z $WORKSPACE_GROUP ]; then
  echo "Must set the environment variable WORKSPACE_USER & WORKSPACE_GROUP - Aborting..."
  exit 1
fi

sed -i "s/^user:x:1000:1000/user:x:${WORKSPACE_USER}:${WORKSPACE_GROUP}/" /etc/passwd
sed -i "s/^user:x:1000/user:x:${WORKSPACE_GROUP}/" /etc/group

chown -R ${WORKSPACE_USER}:${WORKSPACE_GROUP} /home/user
