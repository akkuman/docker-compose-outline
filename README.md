# Docker-Compose-Outline

## Important

**After the installation is complete, you need to go to <SSO_DOMAIN> to change the administrator account password. The default password is admin:123**

## Try

```shell
git clone https://github.com/akkuman/docker-compose-outline.git
cd docker-compose-outline
```

### deploy with ssl(for production)

```shell
MODE=prod SSO_DOMAIN=oauth.fbi.com OUTLINE_DOMAIN=wiki.fbi.com S3_DOMAIN=s3.fbi.com bash genconf.sh
cd deploy
sudo docker compose up -d
```

see https://wiki.fbi.com now

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

# FAQ

1. errror: route: command not found

```shell
apt install -y net-tools
```
