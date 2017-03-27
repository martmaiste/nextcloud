## nextcloud-docker

## Synopsis

This nextcloud docker file includes php-fpm, nginx+ssl, letsencrypt.
By default it uses sqlite but can be configured to use external MySql or PostgreSQL database.
When installed first time, it generates the self-signed SSL certificate. It can later by replaced by generating a Let's Encrypt certificate using included tools.

## Installation

Install and run MariaDB 10

```
docker run -d --name nextcloud-db \
       -v /mnt2/nextcloud-db:/var/lib/mysql \
       -e MYSQL_ROOT_PASSWORD=password \
       -e MYSQL_DATABASE=nextcloud \
       -e MYSQL_USER=nextcloud \
       -e MYSQL_PASSWORD=password \
       mariadb:10
```

Get and build nextcloud-docker

```
git clone https://github.com/martmaiste/nextcloud-docker.git
cd nextcloud-docker
docker build -t nextcloud .
```

Run nextcloud-docker
Note: DOMAIN and EMAIL are mainly used for generating Let's Encrypt certificate later. 

```
docker run --name nextcloud -p 443:4430 \
       --link nextcloud-db:nextcloud-db \
       -v /mnt2/nextcloud-data:/data \
       -v /mnt2/nextcloud-config:/config \
       -v /mnt2/nextcloud-app:/apps2 \
       -e DB_TYPE=mysql \
       -e TZ=Etc/UTC \
       -e DOMAIN=nextcloud.example.com \
       -e EMAIL=you@example.com \
       -t nextcloud
```

## Credits

[Nextcloud 11 Dockerfile by Wonderfall](https://github.com/Wonderfall/dockerfiles/tree/master/nextcloud/11.0)
[Nginx with SSL and Let's Eencrypt support by ngineered](https://github.com/ngineered/nginx-php-fpm)
[Self-signed certificate generator by paulczar](https://raw.githubusercontent.com/paulczar/omgwtfssl/master/generate-certs)

