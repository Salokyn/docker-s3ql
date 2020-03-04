#!/bin/sh

PID=0

term() {
  if [ "$PID" -ne 0 ]
  then
    echo "Shutting down..." >&2
    umount.s3ql "$MOUNTPOINT"
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
  echo "Creating $MOUNTPOINT..."
  mkdir -p "$MOUNTPOINT" || error
fi

# Mount FS
if [ -f "$S3QL_AUTHFILE" ]
then

  # Set S3QL_URL if empty with first storage-url of authfile
  if [ -z "$S3QL_URL" ]
  then
    S3QL_URL=$(sed -n 's/storage-url *: *\(.*\)/\1/p' "$S3QL_AUTHFILE"|head -n1)
  fi

  # shellcheck disable=SC2086
  fsck.s3ql $S3QL_FSCK_OPTIONS --authfile "$S3QL_AUTHFILE" --batch "$S3QL_URL" && FSCK_RESULT=$?
  if [ $FSCK_RESULT -ne 0 ] && [ $FSCK_RESULT -ne 128 ]; then
    echo "fsck.s3ql reported errors! Exit code $FSCK_RESULT - see http://www.rath.org/s3ql-docs/man/fsck.html"
    error
  fi
  
  trap 'term' TERM INT HUP

  # shellcheck disable=SC2086
  mount.s3ql $S3QL_MOUNT_OPTIONS --authfile "$S3QL_AUTHFILE" --fg "$S3QL_URL" "$MOUNTPOINT" & PID=$!

  wait $PID
else
  echo "Authfile not found" >&2
  error
fi
