FROM python:3-alpine AS base

FROM base AS build

ARG TAG=release-2.33

RUN apk --no-cache add curl gnupg jq bzip2 g++ make pkgconfig fuse-dev sqlite-dev
RUN pip install --upgrade setuptools pycrypto defusedxml requests apsw llfuse dugong
RUN pip install --install-option="--prefix=/root/.local" --ignore-installed pycrypto defusedxml requests apsw llfuse dugong
RUN FILE="$(echo "$TAG"|sed s/release/s3ql/)" \
 && curl -sfL "https://github.com/s3ql/s3ql/releases/download/$TAG/$FILE.tar.bz2" -o "/tmp/$FILE.tar.bz2" \
 && gpg2 --batch --recv-key 0xD113FCAC3C4E599F \
 && curl -sfL "https://github.com/s3ql/s3ql/releases/download/$TAG/$FILE.tar.bz2.asc" | gpg2 --batch --verify - "/tmp/$FILE.tar.bz2" \
 && tar -xjf "/tmp/$FILE.tar.bz2" \
 && cd $FILE \
 && python3 setup.py build_ext --inplace \
 && python3 setup.py install --user

FROM base
RUN apk --no-cache add fuse psmisc
COPY --from=build /root/.local/bin/ /usr/local/bin/
COPY --from=build /root/.local/lib/ /usr/local/lib/
COPY ./authfile.sh ./entrypoint.sh ./mount.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/*.sh
ENV MOUNTPOINT=/s3ql
HEALTHCHECK CMD ["/bin/sh","-c","s3qlstat --quiet $MOUNTPOINT"]
ENTRYPOINT ["/bin/sh","/usr/local/bin/entrypoint.sh"]
CMD ["/bin/sh","/usr/local/bin/mount.sh"]
