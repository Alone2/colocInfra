#!/usr/bin/env sh
domain_args="-d wg.a1n.ch -d split.wg.a1n.ch -d chores.wg.a1n.ch"

cp ./config/nginx/nginx_certbot.conf ./config/nginx/nginx.conf

podman-compose up -d 
podman-compose restart nginx

podman-compose exec certbot certbot certonly --webroot -w /var/www/certbot $domain_args

cp ./config/nginx/nginx_default.conf ./config/nginx/nginx.conf

podman-compose restart nginx
podman-compose up -d
