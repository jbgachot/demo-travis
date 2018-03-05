#!/usr/bin/env bash
VERSION="v1.1"
DATE=`date '+%d-%m-%Y %H:%M:%S'`
HOST=`hostname`
apt-get update -q
apt-get install -y nginx
rm /etc/nginx/sites-enabled/default 
cat > /etc/nginx/conf.d/webapp.conf <<EOF
server {
    listen 80;
    server_name _;
    root /var/webapp;
}
EOF
mkdir /var/webapp
cp /tmp/index.html /var/webapp/
sed -i "s#<DATE>#$DATE#" /var/webapp/index.html
sed -i "s#<HOST>#$HOST#" /var/webapp/index.html
systemctl restart nginx
