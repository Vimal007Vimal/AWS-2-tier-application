#!/bin/bash

sudo su 

# Update package list
apt update -y

# Install Apache web server
apt install apache2 -y

# Install PHP and necessary PHP modules
apt install php libapache2-mod-php php-mysql -y

# Install MySQL client
apt install mysql-client -y

# Install archive management tools
apt install rar unrar zip unzip -y

# Install Git
apt install git -y

# Navigate to the web server's root directory
cd /var/www/html/

# Clone the GitHub repository
git clone https://github.com/Vimal007Vimal/AWS-2-tier-application.git

# Remove the default Apache index file
rm -f index.html

# Move the contents of the cloned repository to the web server's root directory
cd AWS-2-tier-application 
mv * /var/www/html/

# Navigate back and remove the empty directory
cd ..
rmdir AWS-2-tier-application

# Restart and enable Apache web server
systemctl restart apache2
systemctl enable apache2
