FROM debian:stable-slim
RUN apt-get update -qq && apt-get install -y s3ql
COPY ./authfile.sh ./entrypoint.sh ./mount.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/*.sh
ENTRYPOINT ["/bin/sh","/usr/local/bin/entrypoint.sh"]
CMD ["/bin/sh","/usr/local/bin/mount.sh"]
