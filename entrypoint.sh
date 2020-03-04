#!/bin/sh -e

S3QL_HOME=/root/.s3ql

# Set default value if not provided
if [ -z "$S3QL_AUTHFILE" ]
then
  S3QL_AUTHFILE="$S3QL_HOME/authinfo2"
fi

export S3QL_HOME
export S3QL_AUTHFILE

authfile.sh
exec "$@"
