FROM php:7.4.19-fpm-alpine

ARG TZ=Asia/Shanghai
ARG PHP_EXTENSIONS=pdo_mysql,mysqli,mbstring,gd,curl,opcache,mcrypt,redis,bcmath,zip,exif,swoole,xlswriter,rdkafka,imagick
ARG CONTAINER_PACKAGE_URL=mirrors.aliyun.com

RUN if [ $CONTAINER_PACKAGE_URL ] ; then sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories ; fi

COPY ./extensions /tmp/extensions
WORKDIR /tmp/extensions
RUN chmod +x install.sh \
    && sh install.sh \
    && rm -rf /tmp/extensions

ADD ./extensions/install-php-extensions  /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions

RUN apk add autoconf make gcc g++ zlib-dev imagemagick

ENV LIBRARY_PATH=/lib:/usr/lib/

RUN apk --no-cache add tzdata \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone


# Fix: https://github.com/docker-library/php/issues/240
RUN apk add libstdc++ --no-cache --repository http://${CONTAINER_PACKAGE_URL}/alpine/edge/community/ --allow-untrusted
RUN apk add --no-cache --repository http://${CONTAINER_PACKAGE_URL}/alpine/v3.12/community/ gnu-libiconv=1.15-r2
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php


# Install composer and change it's cache home
RUN curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer
ENV COMPOSER_HOME=/tmp/composer

# php image's www-data user uid & gid are 82, change them to 1000 (primary user)
RUN apk --no-cache add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data

# install git openssh supervisor
RUN apk add --no-cache bash openssh supervisor sshpass vim git

# install fswatch
COPY ./fswatch-1.16.0.tar.gz /tmp/

WORKDIR /tmp

RUN tar -zxvf fswatch-1.16.0.tar.gz \
    && cd fswatch-1.16.0 \
    && ./configure \
    && make \
    && make install \
    && rm /tmp/fswatch-1.16.0.tar.gz \
    && rm -rf /tmp/fswatch-1.16.0

RUN echo "http://mirrors.aliyun.com/alpine/v3.6/main" > /etc/apk/repositories \
    && echo "http://mirrors.aliyun.com/alpine/v3.6/community" >> /etc/apk/repositories \
    && apk update upgrade \
    && apk add --no-cache procps unzip curl bash tzdata \
	&& apk add yasm && apk add ffmpeg \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

#COPY ./entrypoint.sh /opt/entrypoint.sh

#CMD source /opt/entrypoint.sh

WORKDIR /www