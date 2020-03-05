#!/bin/sh -e

error() {
  echo "An error occured. Exiting $0." >&2
  exit 1
}

# Create Authfile
if [ ! -f "$S3QL_AUTHFILE" ]
then
  echo "Creating $S3QL_AUTHFILE..." >&2
  
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
  } > "$S3QL_AUTHFILE"

  if [ -n "$FS_PASSPHRASE" ]
  then
    echo "fs-passphrase: $FS_PASSPHRASE" >> "$S3QL_AUTHFILE"
  fi

  if [ -n "$BACKEND_OPTIONS" ]
  then
    echo "backend-options: $BACKEND_OPTIONS" >> "$S3QL_AUTHFILE"
  fi
fi

if [ -w "$S3QL_AUTHFILE" ]
then
  chmod 600 "$S3QL_AUTHFILE"
fi
