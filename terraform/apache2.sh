#!/bin/bash
sudo apt update
sudo apt install -y apache2
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
#echo "<h2>Web server IP: $myip</h2></br>Build by terraform" > /var/www/html/index.html
service apache2 reload