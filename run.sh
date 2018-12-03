#!/bin/sh

MOUNTPOINT=/s3ql
S3QL_HOME=/root/.s3ql
AUTHFILE="$S3QL_HOME/authinfo2"
PID=0

term() {
  if [ "$PID" -ne 0 ]
  then
    echo "Shutting down..."
    kill "$PID"
    wait "$PID"
    exit $?
  fi
}

error() {
  echo "An error occured. Exiting." >&2
  exit 1
}

# Create Authfile
if [ ! -f "$AUTHFILE" ]
then
  if [ -z "$S3QL_PROJECT" ] || [ -z "$S3QL_USERNAME" ] || [ -z "$S3QL_PASSWORD" ] || [ -z "$S3QL_URL" ]
  then
    echo "Missing parameters" >&2
    error
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

# Mount FS
if [ -f "$AUTHFILE" ]
then
  fsck.s3ql --backend-options tcp-timeout=30 "$S3QL_URL" || error
  trap 'term' TERM INT HUP
  mount.s3ql --fg --backend-options tcp-timeout=30 "$S3QL_URL" "$MOUNTPOINT" & \
  PID=$!
  wait $PID
fi
