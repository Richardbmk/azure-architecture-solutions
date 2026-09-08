#!/bin/sh
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl stop ufw
sudo systemctl disable ufw
sudo chmod -R 777 /var/www/html
sudo echo "Welcome to MyFitness - WebVM App2 - VM Hostname: $(hostname)" > /var/www/html/index.html
sudo mkdir /var/www/html/app2
sudo echo "Welcome to MyFitness - WebVM App2 - VM Hostname: $(hostname)" > /var/www/html/app2/hostname.html
sudo echo "Welcome to MyFitness - WebVM App2 - App Status Page" > /var/www/html/app2/status.html
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(60, 179, 113);"> <h1>Welcome to MyFitness - WebVM APP-2 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/app2/index.html
sudo curl -H "Metadata:true" --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" -o /var/www/html/app2/metadata.html