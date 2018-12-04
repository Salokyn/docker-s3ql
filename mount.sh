#!/bin/sh

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
