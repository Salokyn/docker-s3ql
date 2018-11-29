#!/bin/sh

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

mount.s3ql --fg --log none --backend-options tcp-timeout=30 "$URL" /s3ql
