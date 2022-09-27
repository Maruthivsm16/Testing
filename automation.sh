#!/bin/bash

name="vadapalli"
s3_bucket="upgrad-vadapallisaimaruthi"

#update the ubuntu 
sudo apt update -y

#Check is Apache2 is installed
if [[ apache2 == $(dpkg --get-selections apache2 | awk '{print $1}') ]]; 
then
	echo "Apache2 is already installed"
else	
	apt install apache2 -y
	echo "Apache2 is installed Now!"
fi

#Ensure that Apache2 service is running
running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running == ${running} ]] ; 
then
	echo "Apache is already running successfully"
else
	systemctl start apache2
	echo "Apache2 is running Now!"
fi

#Ensure Apache2 Service is Enabled
enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled == ${enabled} ]] ; 
then
	echo "Apache2 Service is Enabled successfully"
else	
	systemctl enable apache2
	echo"Apache2 Service is Enabled Now!"
fi

#creating file name
timestamp=$(date '+%d%m%Y-%H%M%S')

#creating a tar file and contains a log files of apache2 server
cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log

#copy logs to s3 bucket
if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]]; 
then
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar

fi
	
bookkeeping="/var/www/html"
# Check if inventory file exists
if [[ ! -f ${bookkeeping}/inventory.html ]]; 
then
	echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${bookkeeping}/inventory.html
fi

# Inserting Logs into the file
if [[ -f ${bookkeeping}/inventory.html ]]; then
    size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${bookkeeping}/inventory.html
fi

# Creating a cron job that runs service in interval of 1 day

if [[ ! -f /etc/cron.d/automation ]]; 
then
	echo "0 0 * * * /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
fi
	
