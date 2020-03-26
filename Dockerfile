FROM python:3.8-alpine AS build

RUN apk --no-cache add curl gnupg jq bzip2 g++ make pkgconfig fuse3-dev sqlite-dev libffi-dev openssl-dev
RUN pip install --user --ignore-installed \
    cryptography defusedxml requests "apsw >= 3.7.0" "trio >= 0.9" "pyfuse3 >= 1.0, < 2.0" "dugong >= 3.4, < 4.0" google-auth google-auth-oauthlib
RUN gpg2 --batch --recv-key 0xD113FCAC3C4E599F
ARG S3QL_VERSION
ARG FILE="s3ql-$S3QL_VERSION"
ARG URL="https://github.com/s3ql/s3ql/releases/download/release-$S3QL_VERSION/$FILE.tar.bz2"
RUN set -x; \
    curl -sfL "$URL" -o "/tmp/$FILE.tar.bz2" \
 && curl -sfL "$URL.asc" | gpg2 --batch --verify - "/tmp/$FILE.tar.bz2" \
 && tar -xjf "/tmp/$FILE.tar.bz2"
WORKDIR $FILE
RUN python3 setup.py build_ext --inplace \
 && python3 setup.py install --user

FROM python:3.8-alpine
RUN apk --no-cache add fuse3 psmisc
COPY --from=build /root/.local/bin/ /usr/local/bin/
COPY --from=build /root/.local/lib/ /usr/local/lib/
COPY ./authfile.sh ./entrypoint.sh ./mount.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/*.sh
ENV MOUNTPOINT=/s3ql
VOLUME /root/.s3ql
HEALTHCHECK CMD ["/bin/sh","-c","s3qlstat --quiet $MOUNTPOINT"]
ENTRYPOINT ["/bin/sh","/usr/local/bin/entrypoint.sh"]
CMD ["/bin/sh","/usr/local/bin/mount.sh"]