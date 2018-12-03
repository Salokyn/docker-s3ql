FROM debian:stable-slim
RUN apt-get update -qq && apt-get install -y s3ql
COPY ./run.sh /usr/local/bin/
RUN chmod 744 /usr/local/bin/run.sh
CMD ["/bin/sh","/usr/local/bin/run.sh"]
