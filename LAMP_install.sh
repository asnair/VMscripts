#! /usr/bin/env bash

###
#
# This script is ported from this script: https://gist.github.com/rrosiek/8190550 which was originally meant as a vagrant provision file.
#
# This script assumes that your web root is the "public" folder
# (Laravel standard).
#
###

# Variables
DBHOST=localhost
DBNAME=dbname
DBUSER=dbuser
DBPASSWD=test

echo -e "\n--- Mkay, installing now... ---\n"

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update #-qq = quiet except errors

echo -e "\n--- Install base packages ---\n"
apt-get -y install vim curl build-essential python-software-properties

echo -e "\n--- Updating packages list ---\n"
apt-get -qq update

# MySQL setup for development purposes ONLY
echo -e "\n--- Install MySQL specific packages and settings ---\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"
apt-get -y install mysql-server phpmyadmin

echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"

echo -e "\n--- Installing PHP-specific packages ---\n"
apt-get -y install php apache2 libapache2-mod-php php-curl php-gd php-mysql php-gettext

echo -e "\n--- Enabling mod-rewrite ---\n"
a2enmod rewrite

echo -e "\n--- Allowing Apache override to all ---\n"
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n--- Setting document root to public directory ---\n"
rm -rf /var/www/html
ln -fs /vagrant/public /var/www/html

echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

echo -e "\n--- Restarting Apache ---\n"
service apache2 restart

echo -e "\n--- Installing Composer for PHP package management ---\n"
curl --silent https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo -e "\n--- Installing NodeJS and NPM ---\n"
apt-get -y install nodejs

echo -e "\n--- Installing javascript components ---\n"
npm install -g gulp bower

echo -e "\n--- Finished Installing Components ---\n"