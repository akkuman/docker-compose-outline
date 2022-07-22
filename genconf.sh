#!/bin/bash

rand_str()
{
    s=`strings /dev/urandom |tr -dc A-Za-z0-9 | head -c$1; echo`
    echo "$s"
}

export MINIO_ROOT_USER=${MINIO_ROOT_USER:-$(rand_str 8)}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-$(rand_str 24)}
export OIDC_CLIENT_ID=${OIDC_CLIENT_ID:-$(rand_str 20)}
export OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET:-$(rand_str 40)}
export CURIP=${CURIP:-`echo $(echo $(ip a | grep $(route -n | grep ^0.0.0.0 | awk '{print $8}') | grep "inet " | awk '{print $2}') | sed 's+/.*++')`}
export SECRET_KEY=${SECRET_KEY:-$(rand_str 64)}
export UTILS_SECRET=${UTILS_SECRET:-$(rand_str 64)}
export SSO_DOMAIN=${SSO_DOMAIN}
export OUTLINE_DOMAIN=${OUTLINE_DOMAIN}
export S3_DOMAIN=${S3_DOMAIN}
export HTTPS_PORTAL_STAGE="production"
export PROTOCOL="http"

MODE=${MODE:-"prod"}
if [ "$MODE" == "dev" ]
then
    export HTTPS_PORTAL_STAGE="local"
elif [ "$MODE" == "staging" ]
then
    export HTTPS_PORTAL_STAGE="staging"
fi

# see https://github.com/SteveLTN/https-portal/tree/d9cbd4c2f91ada8cc7bd366f8f5a577fb7d17d1d#test-locally
https_portal_part="
  https-portal:
    image: steveltn/https-portal
    restart: on-failure:3
    env_file: ./https_portal.env
    ports:
      - 80:80
      - 443:443
    depends_on:
      - wk-outline
      - wk-minio
      - casdoor
    volumes:
      - ./data/ssl_certs:/var/lib/https-portal
    healthcheck:
      test: service nginx status
      interval: 20s
      timeout: 20s
      retries: 5
    networks:
      - wk_net
"

outline_hosts="
    extra_hosts:
      - ${SSO_DOMAIN}:host-gateway
      - ${S3_DOMAIN}:host-gateway
"

# create deploy directory
mkdir -p deploy

if [ ! -z "$SSO_DOMAIN" ] && [ ! -z "$OUTLINE_DOMAIN" ] && [ ! -z "$S3_DOMAIN" ]
then
    # if local stage, add extra_hosts
    if [ "$HTTPS_PORTAL_STAGE" == "local" ]
    then
        insert_line_no=$(echo $(grep -n 'wk-outline:' docker-compose.sample.yml | awk '{print $1+1}' FS=":"))
        awk_command="$(while IFS= read -r line; do echo "print \"$line\""; done <<< $outline_hosts)"
        awk 'NR=='$insert_line_no' {'"$awk_command"'}1' docker-compose.sample.yml > ./deploy/docker-compose.tmp.yml
    fi
    if [ ! -f "./deploy/docker-compose.tmp.yml" ]
    then
        cp docker-compose.sample.yml ./deploy/docker-compose.tmp.yml
    fi
    # if enable domain, then enable https
    export PROTOCOL="https"
    envsubst < "https_portal.sample.env" > "./deploy/https_portal.env"
    # delete port mapping
    sed -i -e '/ports:/d' -e '/- 8000:8000/d' -e '/- 9000:9000/d' -e '/- 3000:3000/d' ./deploy/docker-compose.tmp.yml
    # insert part of https_portal ot docker-compose.yml
    # get next line number which match 'services:'
    insert_line_no=$(echo $(grep -n services: ./deploy/docker-compose.tmp.yml | awk '{print $1+1}' FS=":"))
    # awk_command will be
    # ...
    # print "  https-portal:"
    # print "    image: steveltn/https-portal"
    # print "    restart: on-failure:3"
    # ...
    awk_command="$(while IFS= read -r line; do echo "print \"$line\""; done <<< $https_portal_part)"
    awk 'NR=='$insert_line_no' {'"$awk_command"'}1' ./deploy/docker-compose.tmp.yml > ./deploy/docker-compose.yml
    # delete temp file
    rm -rf ./deploy/docker-compose.tmp.yml
else
    # if disable doamin, then set domain to ip:port
    export SSO_DOMAIN=${CURIP}:8000
    export OUTLINE_DOMAIN=${CURIP}:3000
    export S3_DOMAIN=${CURIP}:9000

    cp docker-compose.sample.yml ./deploy/docker-compose.yml
fi


envsubst < "minio.sample.env" > "./deploy/minio.env"
envsubst < "outline.sample.env" > "./deploy/outline.env"
envsubst < "casdoor_init_data.sample.json" > "./deploy/casdoor_init_data.json"
