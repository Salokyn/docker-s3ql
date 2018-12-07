[![pipeline status](https://gitlab.com/Salokyn/docker-s3ql/badges/master/pipeline.svg)](https://gitlab.com/Salokyn/docker-s3ql/commits/master)

# S3QL

S3QL is a file system that stores all its data online using storage services like Google Storage, Amazon S3, or OpenStack. S3QL effectively provides a hard disk of dynamic, infinite capacity that can be accessed from any computer with internet access.
http://www.rath.org/s3ql-docs/about.html

This project aims to install S3QL in a Docker container and use it in a stack to store data on the cloud through volumes.

## Warning

This project is **experimental** and is **not even fully tested**. To use only for tests purpose.

For now, this very project has only been written for Openstak Swift containers (it may work for other anyway).

## Requirements
`fuse` must be installed on the host.
### Debian
```shell
apt-get install fuse
```

## Environment variables

`S3QL_USERNAME` and `S3QL_PASSWORD`: Cloud service credentials.

`S3QL_PROJECT`: Cloud project or tenant.

`S3QL_URL`: Depends on the backend. See http://www.rath.org/s3ql-docs/backends.html.

`FS_PASSPHRASE`: S3QL FS may be encrypted. This is the passphrase to unlock the AES 256 encryption key.

`S3QL_OPTIONS`: Any option to be added to the `mount.s3ql` command.

## Usage

The image can be used from the project's registry: 

```shell
docker pull registry.gitlab.com/salokyn/docker-s3ql:latest
docker run -d -e S3QL_USERNAME=myLogin \
              -e S3QL_PASSWORD=myPassword \
              -e S3QL_PROJECT=myTenant \
              -e S3QL_URL=swiftks://openstack.backend/REGION:CONTAINER \
              -e FS_PASSPHRASE=mySecretPassphrase \
              -v /s3ql:/s3ql:rw,rshared \
              --cap-add SYS_ADMIN \
              --device /dev/fuse \
              --stop-timeout 10m
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
      - s3ql:/s3ql:rw,rshared
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
    stop_grace_period: 10m
  
  app:
    ...
    volumes:
      - s3ql:/s3ql
    ...
```

Take care to use *rshared* [bind-propagation](https://docs.docker.com/storage/bind-mounts/#configure-bind-propagation) to share S3QL mount with the host or another container.
You should specify a *stop-timout* greater than default 10s since unmounting S3QL may be long.

## Create a S3QL FS
```shell
docker pull registry.gitlab.com/salokyn/docker-s3ql:latest
docker run -ti -e S3QL_USERNAME=myLogin \
               -e S3QL_PASSWORD=myPassword \
               -e S3QL_PROJECT=myTenant \
               -e S3QL_URL=swiftks://openstack.backend/REGION:CONTAINER \
               registry.gitlab.com/salokyn/docker-s3ql:latest \
               mkfs.s3ql swiftks://openstack.backend/REGION:CONTAINER
```
