echo "----Checking for updates----"
sudo apt update -y

if [ -n "$(apache2 -v)" ];
then
	echo "----Apache is installed----"
else
	echo "----Installing apache----"
	sudo apt -y install apache2
fi

echo "----Starting apache server----"
if [ -n "$(sudo systemctl status apache2.service)" ];
then 
	echo "----Apache service is running----"
else
	sudo systemctl start apache2
fi

echo "----Enabling apache server----"
if [ -n "$(sudo systemctl is-enabled apache2)" ];
then
	echo "----Apache is enabled for reboot----"
else
	sudo systemctl enable apache2
fi	

myname=suhaasnandeesh
timestamp=`date +%d%m%Y-%H%M%S`
s3_bucket=upgrad-suhaasnandeesh
log_type=httpd-logs
file_type=tar

tar -cvf $myname-httpd-logs-$timestamp.tar /var/log/apache2/*.log
mv *.tar /tmp

aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

File=/var/www/html/inventory.html
if [ -f "$File" ];
then
	echo "$File exists"
	echo "Appending to log file"
	printf "$log_type\t\t$timestamp\t\t$file_type\t\t$(du -h /tmp/$myname-httpd-logs-$timestamp.tar | awk '{print $1}')\n" >> $File
else
	echo "Creating file inventory.html"
	printf "Log Type\t\tTime Created\t\tType\t\tSize\n" >> /var/www/html/inventory.html
	printf "$log_type\t\t$timestamp\t\t$file_type\t\t$(du -h /tmp/$myname-httpd-logs-$timestamp.tar | awk '{print $1}')\n" >> $File
fi

#CRON job

if [ -n "$( cat /etc/cron.d/* | awk '/automation.sh/' )" ];
then
	echo "Cron job already available"
else
	printf "0 0 * * * root /root/Project/Automation_Project/automation.sh\n" > /etc/cron.d/automation
        echo "Cron job created"
fi
