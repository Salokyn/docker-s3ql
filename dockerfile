FROM debian:stable-slim
RUN apt-get update -qq && apt-get install -y s3ql
COPY ./authinfo2 /root/.s3ql/
COPY ./run.sh /usr/local/bin/
RUN chmod 600 /root/.s3ql/./authinfo2 ; \
    chmod 744 /usr/local/bin/run.sh
CMD ["/bin/sh","-c","/usr/local/bin/run.sh"]
