# S3QL

S3QL is a file system that stores all its data online using storage services like Google Storage, Amazon S3, or OpenStack. S3QL effectively provides a hard disk of dynamic, infinite capacity that can be accessed from any computer with internet access.
http://www.rath.org/s3ql-docs/about.html

This project aims to install S3QL in a Docker container and use it in a stack to store data on the cloud through volumes.

For now, this very project only works with Openstak Swift containers.

The image can be used directly from the project's registry : 

```shell
docker pull registry.gitlab.com/salokyn/docker-s3ql:master
docker run -d -e OS_USER=myLogin \
              -e OS_PASSWORD=myPassword \
              -e OS_PROJECT=myTenant \
              -e OS_URL=openstack.backend/api \
              -e OS_CONTAINER=myContianer \
              -v /s3ql:/s3ql \
              registry.gitlab.com/salokyn/docker-s3ql:master
```