# Docker-Compose-Outline

## Try

```shell
git clone https://github.com/akkuman/docker-compose-outline.git
cd docker-compose-outline
```

### local deploy without ssl(for test)

```shell
CURIP=<your_vps_ip> bash genconf.sh
cd deploy
sudo docker compose up -d
```

see http://<your_vps_ip>:3000 now

### local deploy with ssl(for test)

```shell
MODE=dev SSO_DOMAIN=oauth.fbi.com OUTLINE_DOMAIN=wiki.fbi.com S3_DOMAIN=s3.fbi.com bash genconf.sh
cd deploy
sudo docker compose up -d
```

or use let's encrypt test cert(not recommend)

```shell
MODE=staging SSO_DOMAIN=oauth.fbi.com OUTLINE_DOMAIN=wiki.fbi.com S3_DOMAIN=s3.fbi.com bash genconf.sh
cd deploy
sudo docker compose up -d
```

see https://wiki.fbi.com now

### deploy with ssl(for production)

```shell
MODE=prod SSO_DOMAIN=oauth.fbi.com OUTLINE_DOMAIN=wiki.fbi.com S3_DOMAIN=s3.fbi.com bash genconf.sh
cd deploy
sudo docker compose up -d
```

see https://wiki.fbi.com now

# FAQ

1. errror: route: command not found

```shell
apt install -y net-tools
```

2. I have not changed the DNS resolution record, but I have changed the local hosts file pointing, can I use the domain name test?

you can.

but you need update your ./deploy/docker-compose.yml after run `bash genconf.sh`.

you need add extra_hosts in service `wk-outline`

for example:

from 

```yaml
wk-outline:
  image: outlinewiki/outline:latest
  ...
  depends_on:
    ...
  networks:
    - wk_net
```

to 

```yaml
wk-outline:
  image: outlinewiki/outline:latest
  ...
  depends_on:
      ...
  networks:
      - wk_net  
  extra_hosts:
      - <your_s3_domain>:<your_ip>
      - <your_sso_domain>:<your_ip>
```
