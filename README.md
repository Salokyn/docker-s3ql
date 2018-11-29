# S3QL

S3QL is a file system that stores all its data online using storage services like Google Storage, Amazon S3, or OpenStack. S3QL effectively provides a hard disk of dynamic, infinite capacity that can be accessed from any computer with internet access.
http://www.rath.org/s3ql-docs/about.html

This project aims to install S3QL in a Docker container and use it in a stack to store data on the cloud through volumes.

## Warning

This project is **experimental** and is **not even fully tested**. To use only for tests purpose.

For now, this very project has only been written for Openstak Swift containers (it may work for other anyway).

## Requirements
Host have fuse installed
### Debian
```shell
apt-get install fuse
```

## Usage

The image can be used directly from the project's registry: 

```shell
docker pull registry.gitlab.com/salokyn/docker-s3ql:latest
docker run -d -e S3QL_USERNAME=myLogin \
              -e S3QL_PASSWORD=myPassword \
              -e S3QL_PROJECT=myTenant \
              -e S3QL_URL=openstack.backend/REGION:CONTAINER \
              -e FS_PASSPHRASE=mySecretPassphrase \
              -v /s3ql:/s3ql \
              --cap-add SYS_ADMIN \
              --device /dev/fuse \
              registry.gitlab.com/salokyn/docker-s3ql:latest
```

The best way to use it is in a `docker-compose.yml` file :

```yaml
version: '3.5'

volumes:
  s3ql:

services:
  s3ql:
    image: registry.gitlab.com/salokyn/docker-s3ql
    volumes:
      - s3ql:/s3ql
    environment:
      - S3QL_PASSWORD=myPassword
      - S3QL_USERNAME=myLogin
      - S3QL_PROJECT=myTenant
      - S3QL_URL=swiftks://openstack.backend/REGION:CONTAINER
      - FS_PASSPHRASE=mySecretPassphrase
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse
  
  app:
    ...
    volumes:
      - s3ql:/s3ql
    ...
```
