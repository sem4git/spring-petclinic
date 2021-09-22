#!/bin/bash
#sudo yum -y update
sudo yum -y install epel-release
sudo setenforce Permissive
#sudo yum -y install awscli
sudo curl https://test-backet-66778899.s3.amazonaws.com/java-app/spring-petclinic.jar -o /opt/spring-petclinic/spring-petclinic.jar --create-dirs
sudo curl https://test-backet-66778899.s3.amazonaws.com/conf_app/spring-petclinic.service -o /etc/systemd/system/spring-petclinic.service 
sudo yum -y install java-1.8.0-openjdk
#sudo yum -y install nginx 
sudo systemctl enable spring-petclinic.service
sudo systemctl start spring-petclinic.service

