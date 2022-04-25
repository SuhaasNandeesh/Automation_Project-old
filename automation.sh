sudo apt update -y
sudo apt -y install apache2
sudo systemctl enable apache2
sudo systemctl start apache2

myname=suhaasnandeesh
timestamp=`date +%d%m%Y-%H%M%S`
s3_bucket=upgrad-suhaasnandeesh

tar -cvf $myname-httpd-logs-$timestamp.tar /var/log/apache2/*.log
mv *.tar /tmp

aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar
