[![pipeline status](https://gitlab.com/Salokyn/docker-s3ql/badges/master/pipeline.svg)](https://gitlab.com/Salokyn/docker-s3ql/commits/master)

# S3QL

S3QL is a file system that stores all its data online using storage services like Google Storage, Amazon S3, or OpenStack. S3QL effectively provides a hard disk of dynamic, infinite capacity that can be accessed from any computer with internet access.
http://www.rath.org/s3ql-docs/about.html

This project aims to install S3QL in a Docker container and use it in a stack to store data on the cloud. Since *bind propagation is not configurable for volumes*, it can only be used through bind mounts.

## Warning

This project is **experimental** and **not fully tested**. Use it at your own risk.

So far, it has been tested with the following storage backends:

- [OpenStack Swift](https://docs.openstack.org/swift/latest/) (used in the CI/CD testing stage)
- [DigitalOcean Spaces](https://www.digitalocean.com/products/spaces/) 

If you encounter any issues with other storage backends, feel free to [submit an Issue](https://gitlab.com/Salokyn/docker-s3ql/issues) or, preferably, directly file a [Merge Request](https://gitlab.com/Salokyn/docker-s3ql/merge_requests).

## Requirements
`fuse` must be installed on the host.
### Debian
```shell
apt-get install fuse
```

## Build
S3QL version must be privided in variable `S3QL_VERSION` for the image to be build.

```shell
docker build -t docker-s3ql --build-arg S3QL_VERSION=3.3.2 .
```

## Usage

### Environment variables

- `S3QL_USERNAME` and `S3QL_PASSWORD`: Cloud service credentials.
- `S3QL_PROJECT`: Cloud project or tenant (OpenStack/Swift Backends only).
- `S3QL_URL`: Depends on the backend. See [S3QL backends documentation](http://www.rath.org/s3ql-docs/backends.html).
- `FS_PASSPHRASE`: S3QL FS may be encrypted. This is the passphrase to unlock the AES 256 encryption key.
- `BACKEND_OPTIONS`: Comma separated backend options to be set (ie. 'notls,tcp-timeout=200')
- `S3QL_MOUNT_OPTIONS`: Options be added to the `mount.s3ql` command in addition to `--fg`. See [`mount.s3ql` documentation](http://www.rath.org/s3ql-docs/man/mount.html).
- `S3QL_FSCK_OPTIONS`: Options to be added to the `fsck.s3ql` command in addition to `--batch`. See [`fsck.s3ql` documentation](http://www.rath.org/s3ql-docs/man/fsck.html) .
- `S3QL_AUTHFILE`: If specified, authfile won't be created from environment variables but used as is. Useful when using docker secrects.

### Mount a S3QL FS

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
              --security-opt apparmor:unconfined \
              --stop-timeout 10m \
              registry.gitlab.com/salokyn/docker-s3ql:latest
```

You can also use a `docker-compose.yml` file :

```yaml
version: '3.5'

services:
  s3ql:
    image: registry.gitlab.com/salokyn/docker-s3ql
    volumes:
      - /bind/path/on/host:/s3ql:shared
    environment:
      - S3QL_PASSWORD=myPassword
      - S3QL_USERNAME=myLogin
      - S3QL_PROJECT=myTenant
      - S3QL_URL=swiftks://openstack.backend/REGION:CONTAINER
      - FS_PASSPHRASE=mySecretPassphrase
    security_opt:
      - apparmor:unconfined 
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse
    stop_grace_period: 10m
  
  app:
    ...
    depends_on:
      - s3ql
    volumes:
      - /bind/path/on/host:/s3ql:slave
    ...
```

Take care to use [bind-propagation](https://docs.docker.com/storage/bind-mounts/#configure-bind-propagation) to share S3QL mount with the host or another container.
You should specify a *stop-timout* greater than default 10s since unmounting S3QL may be long.

Do not make a bind mount of an authfile in ~/root/.s3ql since this folder is already stored in a volume. If needed, mount the authfile elsewhere and use `S3QL_AUTHFILE` to specify its path.

### Create a S3QL FS
```shell
docker pull registry.gitlab.com/salokyn/docker-s3ql:latest
docker run -ti -e S3QL_USERNAME=myLogin \
               -e S3QL_PASSWORD=myPassword \
               -e S3QL_PROJECT=myTenant \
               -e S3QL_URL=swiftks://openstack.backend/REGION:CONTAINER \
               registry.gitlab.com/salokyn/docker-s3ql:latest \
               mkfs.s3ql swiftks://openstack.backend/REGION:CONTAINER
```
