#!/bin/sh
# Docker
apt-get update

apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io


# Docker Compose 
curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# CTF data

mkdir /var/CTF
cd /var/CTF/

git clone https://github.com/ESCSecureCoding/CTFd.git	
git clone --single-branch --branch CTFd-Auto-Submit https://github.com/ESCSecureCoding/juice-shop.git
curl https://raw.githubusercontent.com/ESCSecureCoding/CTFMetaFiles/master/exxeta.yml > exxeta.yml

# load modified docker-compose config
curl https://raw.githubusercontent.com/ESCSecureCoding/CTFMetaFiles/master/docker-compose.yml > CTFd/docker-compose.yml
curl https://raw.githubusercontent.com/ESCSecureCoding/CTFMetaFiles/master/Dockerfile > CTFd/Dockerfile
curl https://raw.githubusercontent.com/ESCSecureCoding/CTFMetaFiles/master/base.html > CTFd/CTFd/themes/core/templates/base.html
curl https://raw.githubusercontent.com/ESCSecureCoding/CTFMetaFiles/master/init__init__.py > CTFd/CTFd/utils/initialization/__init__.py
curl https://raw.githubusercontent.com/ESCSecureCoding/CTFMetaFiles/master/login.html > CTFd/CTFd/themes/core/templates/login.html
curl https://raw.githubusercontent.com/ESCSecureCoding/CTFMetaFiles/master/register.html > CTFd/CTFd/themes/core/templates/register.html

mkdir CTFd/CTFd/plugins/autodeploy
curl https://raw.githubusercontent.com/ESCSecureCoding/CTFMetaFiles/master/__init__.py > CTFd/CTFd/plugins/autodeploy/__init__.py

cd juice-shop
docker build . --tag juice_shop

# Add user to the docker group
# Warning: The docker group grants privileges equivalent to the root user. 
usermod -aG docker ubuntu

# Configure Docker to start on boot
systemctl enable docker

# Setup Proxy
docker network create http_proxy
docker run --detach --name nginx-proxy --network http_proxy --publish 80:80 --publish 443:443 --volume /etc/nginx/certs --volume /etc/nginx/vhost.d --volume /usr/share/nginx/html --volume /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
docker run --detach --name nginx-proxy-letsencrypt --network http_proxy --volumes-from nginx-proxy --volume /var/run/docker.sock:/var/run/docker.sock:ro --env "DEFAULT_EMAIL=ediz.turcan@exxeta.com" jrcs/letsencrypt-nginx-proxy-companion

docker-compose -f /var/CTF/CTFd/docker-compose.yml up
