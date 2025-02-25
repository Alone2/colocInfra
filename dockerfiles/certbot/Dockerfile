FROM ubuntu:latest

WORKDIR /app

COPY ./start.sh /app/start.sh

RUN apt update && \
    apt install -y software-properties-common && \
    add-apt-repository universe && \
    add-apt-repository -r ppa:certbot/certbot && \
    apt update && \
    mkdir /onlyofficedata && \
    mkdir /onlyofficedata/certs && \
    apt install -y certbot

CMD ["/bin/sh","start.sh"]
