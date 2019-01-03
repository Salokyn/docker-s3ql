#!/bin/sh

S3QL_HOME=/root/.s3ql
AUTHFILE="$S3QL_HOME/authinfo2"

error() {
  echo "An error occured. Exiting $0." >&2
  exit 1
}

# Create Authfile
if [ ! -f "$AUTHFILE" ]
then
  echo "Creating $AUTHFILE..." >&2
  
  if [ -z "$S3QL_USERNAME" ] || [ -z "$S3QL_PASSWORD" ] || [ -z "$S3QL_URL" ]
  then
    echo "Missing \$S3QL_* environment variables." >&2
    error
  fi

  if [ ! -d "$S3QL_HOME" ]
  then
    mkdir -p "$S3QL_HOME" || error
  fi

  S3QL_LOGIN=$([ -z "$S3QL_PROJECT" ] && echo "$S3QL_USERNAME" || echo "$S3QL_PROJECT:$S3QL_USERNAME")

  {
    echo "[s3ql]";
    echo "backend-login: $S3QL_LOGIN";
    echo "backend-password: $S3QL_PASSWORD";
    echo "storage-url: $S3QL_URL"
  } > "$AUTHFILE"

  if [ -n "$FS_PASSPHRASE" ]
  then
    echo "fs-passphrase: $FS_PASSPHRASE" >> "$AUTHFILE"
  fi

  chmod 600 "$AUTHFILE"
fi
