#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "<html><h1>Welcome to your Apache Web Server</h1></html>" > /var/www/html/index.html