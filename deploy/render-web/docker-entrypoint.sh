#!/bin/sh
set -e
PORT="${PORT:-80}"
export PORT
sed "s/__PORT__/${PORT}/g" /nginx.conf.template > /etc/nginx/conf.d/default.conf
exec nginx -g "daemon off;"
