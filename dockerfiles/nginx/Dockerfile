FROM alpine:latest

WORKDIR /app

RUN     apk add --update --no-cache nginx \
                                    nginx-mod-http-headers-more

CMD ["nginx", "-g", "daemon off;"]
