#!/usr/bin/env sh
domain_args="-d wg.a1n.ch -d split.wg.a1n.ch -d chores.wg.a1n.ch"

cp ./config/nginx_active/nginx_certbot.conf ./config/nginx_active/nginx.conf

docker compose up -d 
docker compose restart nginx

docker compose exec certbot certbot certonly --webroot -w /var/www/certbot $domain_args

cp ./config/nginx_active/nginx_default.conf ./config/nginx_active/nginx.conf

docker compose restart nginx
docker compose up -d
