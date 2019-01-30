#!/bin/sh

S3QL_HOME=/root/.s3ql
AUTHFILE="$S3QL_HOME/authinfo2"
PID=0

term() {
  if [ "$PID" -ne 0 ]
  then
    echo "Shutting down..." >&2
    kill "$PID"
    wait "$PID"
    exit $?
  fi
}

error() {
  echo "An error occured. Exiting $0." >&2
  exit 1
}

# Create mountpoint if not exists
if [ ! -d "$MOUNTPOINT" ] 
then
  mkdir -p "$MOUNTPOINT" || error
fi

# Mount FS
if [ -f "$AUTHFILE" ]
then
  # shellcheck disable=SC2086
  fsck.s3ql $S3QL_FSCK_OPTIONS --batch "$S3QL_URL" || error
  
  trap 'term' TERM INT HUP

  # shellcheck disable=SC2086
  mount.s3ql $S3QL_MOUNT_OPTIONS --fg "$S3QL_URL" "$MOUNTPOINT" & PID=$!

  wait $PID
else
  echo "Authfile not found"  >&2
  error
fi
