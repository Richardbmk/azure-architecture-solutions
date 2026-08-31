#!/bin/sh
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
sudo systemctl stop ufw
sudo systemctl disable ufw
sudo chmod -R 777 /var/www/html
sudo echo "Welcome to myFitness - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/index.html
sudo mkdir /var/www/html/webvm
sudo echo "Welcome to myFitness - WebVM App1 - VM Hostname: $(hostname)" > /var/www/html/webvm/hostname.html
sudo echo "Welcome to myFitness - WebVM App1 - App Status Page" > /var/www/html/webvm/status.html
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(250, 210, 210);"> <h1>Welcome to Stack Simplify - WebVM APP-1 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/webvm/index.html
sudo curl -H "Metadata:true" --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-09-01" -o /var/www/html/webvm/metadata.html
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft-prod.gpg
sudo chmod go+r /etc/apt/keyrings/microsoft-prod.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/repos/azure-cli/ $(. /etc/os-release && echo $VERSION_CODENAME) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y azure-cli
sudo az storage blob download --container-name ${storage_container} --file /etc/apache2/conf-available/app1.conf --name app1.conf --account-name ${storage_account_name} --account-key ${storage_account_key}
sudo a2enmod proxy proxy_http
sudo a2enconf app1
sudo systemctl reload apache2