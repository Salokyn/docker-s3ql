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
  fsck.s3ql --batch "$S3QL_URL" || error
  
  trap 'term' TERM INT HUP

  if [ -n "$S3QL_OPTIONS" ]
  then
    mount.s3ql "$S3QL_OPTIONS" --fg "$S3QL_URL" "$MOUNTPOINT" & PID=$!
  else
    mount.s3ql --fg "$S3QL_URL" "$MOUNTPOINT" & PID=$!
  fi

  wait $PID
else
  echo "Authfile not found"  >&2
  error
fi
