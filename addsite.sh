#!/bin/bash
echo "127.0.0.1 $1.dev" >> /etc/hosts
echo "<VirtualHost *:80>
    ServerName $1.dev
    DocumentRoot \"/home/$SUDO_USER/www/$1\"
    <Directory / >
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>" >> /etc/apache2/sites-available/$1.conf
mkdir /home/$SUDO_USER/www/$1
echo $1 > /home/$SUDO_USER/www/$1/index.html
chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/www/$1
a2ensite $1
apache2ctl restart

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then

    mysql -e "CREATE DATABASE $1 /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -e "CREATE USER $1@localhost IDENTIFIED BY '$1';"
    mysql -e "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"

# If /root/.my.cnf doesn't exist then it'll ask for root password
else
    echo "Please enter root user MySQL password!"
    read -s rootpasswd
    mysql -uroot -p${rootpasswd} -e "CREATE DATABASE $1 /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -uroot -p${rootpasswd} -e "CREATE USER $1@localhost IDENTIFIED BY '$1';"
    mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON $1.* TO '$1'@'localhost';"
    mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
fi
