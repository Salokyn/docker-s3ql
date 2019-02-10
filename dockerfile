FROM registry.gitlab.com/salokyn/docker-s3ql/build-env AS build

ARG TAG=release-3.0
RUN set -x; \
    FILE="$(echo "$TAG"|sed s/release/s3ql/)" \
 && curl -sfL "https://github.com/s3ql/s3ql/releases/download/$TAG/$FILE.tar.bz2" -o "/tmp/$FILE.tar.bz2" \
 && curl -sfL "https://github.com/s3ql/s3ql/releases/download/$TAG/$FILE.tar.bz2.asc" | gpg2 --batch --verify - "/tmp/$FILE.tar.bz2" \
 && tar -xjf "/tmp/$FILE.tar.bz2" \
 && cd $FILE \
 && python3 setup.py build_ext --inplace \
 && python3 setup.py install --user

FROM python:3-alpine
RUN apk --no-cache add fuse psmisc
COPY --from=build /root/.local/bin/ /usr/local/bin/
COPY --from=build /root/.local/lib/ /usr/local/lib/
COPY ./authfile.sh ./entrypoint.sh ./mount.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/*.sh
ENV MOUNTPOINT=/s3ql
HEALTHCHECK CMD ["/bin/sh","-c","s3qlstat --quiet $MOUNTPOINT"]
ENTRYPOINT ["/bin/sh","/usr/local/bin/entrypoint.sh"]
CMD ["/bin/sh","/usr/local/bin/mount.sh"]
