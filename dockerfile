FROM python:3-alpine AS build
RUN apk --no-cache add curl gnupg jq bzip2 g++ make pkgconfig fuse-dev sqlite-dev
RUN pip install --upgrade --no-cache-dir setuptools pycrypto defusedxml requests apsw llfuse dugong
RUN TAG=$(curl -s "https://api.github.com/repos/s3ql/s3ql/releases/latest"|jq -r .tag_name -) \
 && FILE=$(echo "$TAG"|sed s/release/s3ql/) \
 && curl -L "https://github.com/s3ql/s3ql/releases/download/$TAG/$FILE.tar.bz2" | tar -xj \
 && cd $FILE \
 && python3 setup.py build_ext --inplace \
 && python3 setup.py install

FROM python:3-alpine
RUN apk --no-cache add fuse psmisc procps
COPY --from=build /usr/local/bin/ /usr/local/bin/
COPY --from=build /usr/local/lib/ /usr/local/lib/
COPY ./authfile.sh ./entrypoint.sh ./mount.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/*.sh
ENV MOUNTPOINT=/s3ql
HEALTHCHECK CMD ["/bin/sh","-c","s3qlstat --quiet $MOUNTPOINT"]
ENTRYPOINT ["/bin/sh","/usr/local/bin/entrypoint.sh"]
CMD ["/bin/sh","/usr/local/bin/mount.sh"]
