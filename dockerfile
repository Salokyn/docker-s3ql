FROM debian:stable-slim
RUN apt-get update -qq && apt-get install -y s3ql
COPY ./authinfo2 /root/.s3ql/
RUN chmod 600 /root/.s3ql/./authinfo2
CMD sed -i "s/\$OS_PASSWORD/$OS_PASSWORD/" /root/.s3ql/authinfo2 \
&& sed -i "s/\$OS_USER/$OS_USER/" /root/.s3ql/authinfo2 \
&& sed -i "s/\$OS_URL/$OS_URL/" /root/.s3ql/authinfo2 \
&& sed -i "s/\$OS_PROJECT/$OS_PROJECT/" /root/.s3ql/authinfo2 \
&& sed -i "s/\$OS_CONTAINER/$OS_CONTAINER/" /root/.s3ql/authinfo2 \
&& mount.s3ql --fg --log none --backend-options tcp-timeout=30 "swiftks://$OS_URL:$OS_CONTAINER" /s3ql
