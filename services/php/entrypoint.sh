#!/bin/sh

php-fpm &

supervisord -n -c /etc/supervisor/supervisord.conf