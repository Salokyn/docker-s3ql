#!/bin/bash

MOUNTPOINT=/s3ql
S3QL_HOME=/root/.s3ql
AUTHFILE="$S3QL_HOME/authinfo2"

# Create Authfile
if [ ! -f "$AUTHFILE" ]
then
  if [ -z "$S3QL_PROJECT" ] || [ -z "$S3QL_USERNAME" ] || [ -z "$S3QL_PASSWORD" ] || [ -z "$S3QL_URL" ]
  then
    echo "Missing parameters" >&2
    exit 1
  fi

  if [ ! -d "$S3QL_HOME" ]
  then
    mkdir -p "$S3QL_HOME"
  fi

  {
    echo "[s3ql]";
    echo "backend-login: $S3QL_PROJECT:$S3QL_USERNAME";
    echo "backend-password: $S3QL_PASSWORD";
    echo "storage-url: $S3QL_URL"
  } > "$AUTHFILE"

  if [ -n "$FS_PASSPHRASE" ]
  then
    echo "fs-passphrase: $FS_PASSPHRASE" >> "$AUTHFILE"
  fi

  chmod 600 "$AUTHFILE"
fi

# Create mountpoint if not exists
[ ! -d "$MOUNTPOINT" ] && mkdir -p "$MOUNTPOINT"

if [ -f "$AUTHFILE" ]
then
  fsck.s3ql --log none --backend-options tcp-timeout=30 "$S3QL_URL" && \
  mount.s3ql --fg --log none --backend-options tcp-timeout=30 "$S3QL_URL" "$MOUNTPOINT"
fi
