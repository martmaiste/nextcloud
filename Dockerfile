FROM alpine:edge

ARG NEXTCLOUD_VERSION=11.0.2
ARG GNU_LIBICONV_VERSION=1.15
ARG GPG_nextcloud="2880 6A87 8AE4 23A2 8372  792E D758 99B9 A724 937A"

ENV UID=1000 GID=1000 \
    UPLOAD_MAX_SIZE=10G \
    APC_SHM_SIZE=128M \
    OPCACHE_MEM_SIZE=128 \
    CRON_PERIOD=15m \
    CRON_MEMORY_LIMIT=1g \
    TZ=Etc/UTC \
    DB_TYPE=sqlite3 \
    EMAIL=hostmaster@localhost \
    DOMAIN=localhost

RUN echo "https://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
 && BUILD_DEPS=" \
    gnupg \
    tar \
    build-base \
    autoconf \
    automake \
    pcre-dev \
    libtool \
    libffi-dev \
    openssl-dev \
    python-dev \
    samba-dev" \
 && apk -U upgrade && apk add \
    ${BUILD_DEPS} \
    bash \
    python \
    py-pip \   
    nginx \
    s6 \
    libressl \
    ca-certificates \
    libsmbclient \
    samba-client \
    su-exec \
    tzdata \
    php7 \
    php7-fpm \
    php7-intl \
    php7-mbstring \
    php7-curl \
    php7-gd \
    php7-fileinfo \
    php7-mcrypt \
    php7-opcache \
    php7-json \
    php7-session \
    php7-pdo \
    php7-dom \
    php7-ctype \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pgsql \
    php7-pdo_sqlite \
    php7-sqlite3 \
    php7-zlib \
    php7-zip \
    php7-xmlreader \
    php7-xml \
    php7-xmlwriter \
    php7-posix \
    php7-openssl \
    php7-ldap \
    php7-ftp \
    php7-pcntl \
    php7-exif \
    php7-pear \
    php7-dev \
 && pecl install smbclient apcu redis \
 && cd /tmp && wget -q http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${GNU_LIBICONV_VERSION}.tar.gz \
 && tar xzf libiconv-${GNU_LIBICONV_VERSION}.tar.gz && cd libiconv-${GNU_LIBICONV_VERSION} \
 && ./configure --prefix=/usr/local \
 && make && make install && libtool --finish /usr/local/lib && cd /tmp \
 && wget -q http://is1.php.net/get/php-7.1.2.tar.gz/from/this/mirror -O php7.tar.gz \
 && tar xzf php7.tar.gz && cd /tmp/php-7.1.2/ext/iconv && phpize7 \
 && ./configure --with-iconv=/usr/local --with-php-config=/usr/bin/php-config7 \
 && make && cp modules/iconv.so /usr/lib/php7 && cd /tmp \
 && echo "extension=iconv.so" > /etc/php7/conf.d/00_iconv.ini \
 && echo "extension=smbclient.so" > /etc/php7/conf.d/00_smbclient.ini \
 && echo "extension=redis.so" > /etc/php7/conf.d/redis.ini \
 && sed -i 's|;session.save_path = "/tmp"|session.save_path = "/data/session"|g' /etc/php7/php.ini \
 && pip install -U pip \
 && pip install -U certbot \
 && mkdir -p /etc/letsencrypt/webrootauth \
 && mkdir -p /etc/letsencrypt/live/localhost \
 && wget https://raw.githubusercontent.com/paulczar/omgwtfssl/master/generate-certs -O /usr/local/bin/generate-certs \
 && mkdir /nextcloud \
 && NEXTCLOUD_TARBALL="nextcloud-${NEXTCLOUD_VERSION}.tar.bz2" \
 && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL} \
 && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}.sha512 \
 && wget -q https://download.nextcloud.com/server/releases/${NEXTCLOUD_TARBALL}.asc \
 && wget -q https://nextcloud.com/nextcloud.asc \
 && echo "Verifying both integrity and authenticity of ${NEXTCLOUD_TARBALL}..." \
 && CHECKSUM_STATE=$(echo -n $(sha512sum -c ${NEXTCLOUD_TARBALL}.sha512) | tail -c 2) \
 && if [ "${CHECKSUM_STATE}" != "OK" ]; then echo "Warning! Checksum does not match!" && exit 1; fi \
 && gpg --import nextcloud.asc \
 && FINGERPRINT="$(LANG=C gpg --verify ${NEXTCLOUD_TARBALL}.asc ${NEXTCLOUD_TARBALL} 2>&1 \
  | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" \
 && if [ -z "${FINGERPRINT}" ]; then echo "Warning! Invalid GPG signature!" && exit 1; fi \
 && if [ "${FINGERPRINT}" != "${GPG_nextcloud}" ]; then echo "Warning! Wrong GPG fingerprint!" && exit 1; fi \
 && echo "All seems good, now unpacking ${NEXTCLOUD_TARBALL}..." \
 && tar xjf ${NEXTCLOUD_TARBALL} --strip 1 -C /nextcloud \
 && apk del ${BUILD_DEPS} php7-pear php7-dev \
 && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg

COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php7/php-fpm.conf
COPY opcache.ini /etc/php7/conf.d/00_opcache.ini
COPY apcu.ini /etc/php7/conf.d/apcu.ini
COPY run.sh /usr/local/bin/run.sh
COPY setup.sh /usr/local/bin/setup.sh
COPY occ /usr/local/bin/occ
COPY s6.d /etc/s6.d
COPY letsencrypt-setup /usr/local/bin/letsencrypt-setup
COPY letsencrypt-renew /usr/local/bin/letsencrypt-renew

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*
RUN chmod +x /usr/local/bin/letsencrypt-setup /usr/local/bin/letsencrypt-renew

VOLUME /data /config /apps2

EXPOSE 8888 4430

LABEL description="A server software for creating file hosting services" \
      nextcloud="Nextcloud v${NEXTCLOUD_VERSION}" \
      maintainer="ull <mart.maiste@gmail.com>"

CMD ["run.sh"]
