#!/bin/bash

export MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY:-`openssl rand -hex 4`}
export MINIO_SECRET_KEY=${MINIO_SECRET_KEY:-`openssl rand -hex 12`}
export OIDC_CLIENT_ID=${OIDC_CLIENT_ID:-`openssl rand -hex 10`}
export OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET:-`openssl rand -hex 20`}
export CURIP=${CURIP:-`echo $(echo $(ip a | grep $(route -n | grep ^0.0.0.0 | awk '{print $8}') | grep "inet " | awk '{print $2}') | sed 's+/.*++')`}
export SECRET_KEY=${SECRET_KEY:-`openssl rand -hex 32`}
export UTILS_SECRET=${UTILS_SECRET:-`openssl rand -hex 32`}

envsubst < "minio.sample.env" > "minio.env"
envsubst < "outline.sample.env" > "outline.env"
envsubst < "casdoor_init_data.sample.json" > "casdoor_init_data.json"
