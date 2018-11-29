#!/bin/bash

MOUNTPOINT=/s3ql

if [ -n "$OS_PROJECT" ]
then
  export URL="swiftks://$OS_URL:$OS_CONTAINER"
  sed -i "s#\$PASSWORD#$OS_PASSWORD#;
          s#\$USER#$OS_USER#;
          s#\$URL#$URL#;
          s#\$PROJECT#$OS_PROJECT#;
          s#\$CONTAINER#$OS_CONTAINER#" /root/.s3ql/authinfo2
else
  echo "No case foud" >&2
  exit 1
fi

# Create mountpoint if not exists
[ ! -d "$MOUNTPOINT" ] && makdir -p "$MOUNTPOINT"

if [ -n "$FS_PASSWORD" ]
then
  mount.s3ql --fg --log none --backend-options tcp-timeout=30 "$URL" "$MOUNTPOINT" <<< "$FS_PASSWORD"
else
  mount.s3ql --fg --log none --backend-options tcp-timeout=30 "$URL" "$MOUNTPOINT"
fi
