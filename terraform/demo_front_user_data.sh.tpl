#!/bin/bash
sudo setenforce Permissive
echo '
[Unit]
Description=Java Spring Pet Clinic
After=syslog.target network.target
[Service]
WorkingDirectory=/opt/spring-petclinic
ExecStart=/usr/bin/java -jar /opt/spring-petclinic/spring-petclinic.jar
RestartSec=10
SyslogIdentifier=spring-petclinic
User=root
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
Environment=MYSQL_USER="${app_db_user}"
Environment=MYSQL_PASS="${app_db_password}"
Environment=MYSQL_URL="${app_db_url}"
Environment=spring_profiles_active="mysql"
[Install]
WantedBy=multi-user.target
' | sudo tee /etc/systemd/system/spring-petclinic.service
sudo mkdir /opt/spring-petclinic
sudo curl https://${s3_name}.s3.amazonaws.com/java-app/spring-petclinic.tgz | sudo tar -xzf -  -C /opt/spring-petclinic
sudo mv /opt/spring-petclinic/spring-petclinic-*-SNAPSHOT.jar /opt/spring-petclinic/spring-petclinic.jar
sudo yum -y install java-1.8.0-openjdk
sudo systemctl enable spring-petclinic.service
sudo systemctl start spring-petclinic.service

