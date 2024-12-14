#!/bin/bash

# Define variables
REPO_URL="https://github.com/ezra-ai/ustreamer.git"
CLONE_DIR="ustreamer"
GIT_SSH_PATH=$1

rw

# Check if SSH key path is provided
if [ -z "$GIT_SSH_PATH" ]; then
  echo "Usage: $0 <path-to-ssh-key>"
  exit 1
fi

# Clone the repository
if [ -d "$CLONE_DIR" ]; then
  echo "Directory $CLONE_DIR already exists."
else
  echo "Cloning repository from $REPO_URL..."
  GIT_SSH_COMMAND="ssh -i \"$GIT_SSH_PATH\"" git clone "$REPO_URL"
  echo "pull latest code from repository $REPO_URL..."
  GIT_SSH_COMMAND="ssh -i \"$GIT_SSH_PATH\"" git pull
fi

# Change to the project directory
cd "$CLONE_DIR" || exit

if [ -f "Makefile" ]; then
  make
else
  echo "No known setup instructions found. Please manually run the necessary commands."
fi

cd src/
echo "service stop.."
systemctl stop kvmd.service || echo "Failed to stop kvmd.service."
echo "kvmd.service stopped.."
mv /usr/bin/ustreamer /usr/bin/ustreamer_bkp
cp ustreamer.bin /usr/bin/ustreamer
mv /usr/bin/ustreamer-dump /usr/bin/ustreamer_dump_bkp
cp ustreamer-dump.bin /usr/bin/ustreamer-dump
systemctl start kvmd.service || echo "Failed to start kvmd.service."
echo "kvmd.service started"
