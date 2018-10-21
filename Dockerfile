# SOS base Dockerfile 
# SOS Base docker image
#
# Uso: [sudo] docker build [ -t name_image:tag_image ] --build-arg DB_ROOT_PASSWORD=your_db_root_user_password .

FROM debian:stretch
ARG DB_ROOT_PASSWORD

#Aggiorno apt e installo wget e altri due pacchetti per l'installazione di php7.2
RUN apt update -y && apt-get install -y wget ca-certificates apt-transport-https 

#Preparazione all'installazione di mysql 8
RUN apt-get install -y lsb-release gnupg && \
    wget --user-agent="Mozilla" -O mysql-apt-config_0.8.10-1_all.deb https://dev.mysql.com/get/mysql-apt-config_0.8.10-1_all.deb && \
    export DEBIAN_FRONTEND="noninteractive" && \
    echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections && \
    echo "mysql-community-server mysql-community-server/root-pass password $DB_ROOT_PASSWORD" | debconf-set-selections && \
    echo "mysql-community-server mysql-community-server/re-root-pass password $DB_ROOT_PASSWORD" | debconf-set-selections && \
    echo "mysql-community-server mysql-server/default-auth-override select Use Strong Password Encryption (RECOMMENDED)" | debconf-set-selections &&\
    dpkg -i mysql-apt-config_0.8.10-1_all.deb && \
    rm mysql-apt-config_0.8.10-1_all.deb
#Preparazione all'installazione di nginx
RUN wget http://nginx.org/keys/nginx_signing.key && \
    apt-key add nginx_signing.key && \
    echo "deb http://nginx.org/packages/debian/ stretch nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src http://nginx.org/packages/debian/ stretch nginx" > /etc/apt/sources.list.d/nginx.list && \
    rm nginx_signing.key
#Preparazione all'installazione di php7.2
RUN wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - && \
    echo "deb https://packages.sury.org/php/ stretch main" > /etc/apt/sources.list.d/php.list 

#Aggiorno i pacchetti e installo mysql 8.0, php7.2 e nginx
RUN apt-get update -y && apt-get install -y \
    php7.2-cli php7.2-common php7.2-mysql php7.2-fpm php7.2-mbstring php7.2-xml php7.2-curl php7.2-bz2 \
    mysql-server=8.0.12-1debian9 \ 
    nginx

#Creo la cartella per avviare php7.2 correttamente
RUN mkdir /run/php && \
    chown www-data:www-data /run/php && chmod 755 /run/php 

#Avvio i servizi al riavvio
ENTRYPOINT /etc/init.d/nginx start && \ 
    /etc/init.d/mysql start && \
    /etc/init.d/php7.2-fpm start && echo "[ ok ] Starting php7.2-fpm: ok." && \
    /bin/bash
