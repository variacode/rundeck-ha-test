#!/bin/bash

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password asdf'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password asdf'
sudo apt-get -y install mysql-server

echo "Configuring mysql and creating rundeck user and database..."
mysql -uroot -pasdf -e "create user rundeck identified by 'rundeck';"
mysql -uroot -pasdf -e "create database rundeck;"
mysql -uroot -pasdf -e "grant all privileges on rundeck.* to rundeck;"
mysql -uroot -pasdf -e "flush privileges;"

sudo sed -i.old /etc/mysql/my.cnf -e "s:bind-address.*:bind-address = 0.0.0.0:"
sudo service mysql restart
echo "Done configuring"
