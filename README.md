## Nextcloud Docker using php-fpm, Nginx reverse proxy with SSL and Let's Encrypt support 

### About

This Nextcloud Docker uses php-fpm, Nginx reverse proxy with SSL and Let's Encrypt.
By default it uses SQLite but can be configured to use external MySQL or PostgreSQL database.
At installation, the self-signed SSL certificate is generated. This can later replaced by generating a Let's Encrypt certificate using included tools.

### Installation

Install and run MariaDB 10

Random MySQL root password is generated at install time and outputed to messages log.

Database and user for Nextcloud is also created.

```
docker run -d --name nextcloud-db \
       -v /mnt2/nextcloud-db:/var/lib/mysql \
       -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
       -e MYSQL_DATABASE=nextcloud \
       -e MYSQL_USER=nextcloud \
       -e MYSQL_PASSWORD=password \
       mariadb:10
```

Install and run Nextcloud Docker

```
docker run -d --name nextcloud -p 80:8080 -p 443:8443 \
       --link nextcloud-db:nextcloud-db \
       -v /mnt2/nextcloud-data:/data \
       -v /mnt2/nextcloud-config:/config \
       -v /mnt2/nextcloud-app:/apps2 \
       -e UID=1000 -e GID=1000 \
       -e UPLOAD_MAX_SIZE=10G \
       -e APC_SHM_SIZE=128M \
       -e OPCACHE_MEM_SIZE=128 \
       -e CRON_PERIOD=15m \
       -e DB_TYPE=mysql \
       -e DB_HOST=nextcloud-db \
       -e DB_USER=nextcloud \
       -e DB_PASSWORD=password \
       -e TZ=Etc/UTC \
       -e DOMAIN=localhost \
       -e EMAIL=hostmaster@localhost \
       martmaiste/nextcloud
```

### Building

```
git clone https://github.com/martmaiste/nextcloud.git
docker build -t nextcloud nextcloud
```

Run nextcloud-docker

```
docker run -d --name nextcloud -p 80:8888 -p 443:4430 \
       --link nextcloud-db:nextcloud-db \
       -v /mnt2/nextcloud-data:/data \
       -v /mnt2/nextcloud-config:/config \
       -v /mnt2/nextcloud-app:/apps2 \
       -e UID=1000 -e GID=1000 \
       -e UPLOAD_MAX_SIZE=10G \
       -e APC_SHM_SIZE=128M \
       -e OPCACHE_MEM_SIZE=128 \
       -e CRON_PERIOD=15m \
       -e DB_TYPE=mysql \
       -e DB_HOST=nextcloud-db \
       -e DB_USER=nextcloud \
       -e DB_PASSWORD=password \
       -e TZ=Etc/UTC \
       -e DOMAIN=localhost \
       -e EMAIL=hostmaster@localhost \
       -t nextcloud
```
DOMAIN and EMAIL are mainly used for generating Let's Encrypt certificate later. Remove if not needed.

Nextcloud needs to be accessible on ports 80 and 443 for generating Let's Encrypt certificates.

### Credits

[Nextcloud 11 Dockerfile by Wonderfall](https://github.com/Wonderfall/dockerfiles/tree/master/nextcloud/11.0)

[Nginx with SSL and Let's Eencrypt support by ngineered](https://github.com/ngineered/nginx-php-fpm)

[Self Signed SSL Certificate Generator by paulczar](https://github.com/paulczar/omgwtfssl)
