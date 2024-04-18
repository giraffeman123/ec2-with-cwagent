#!/bin/bash

#Instalacion paquetes necesarios
sudo apt-get update

#install java 17
sudo apt-get -y install openjdk-17-jdk openjdk-17-jre
export JAVA_HOME="/usr/lib/jvm/java-1.17.0-openjdk-amd64"
java -version

#install maven
sudo apt-get -y install maven
mvn -version

#install and configure tomcat 10
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.19/bin/apache-tomcat-10.1.19.tar.gz
sudo tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1

sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin

cat > /home/ubuntu/tomcat.service <<EOF
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo mv /home/ubuntu/tomcat.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo systemctl status tomcat

#install and configure java spring boot project
cd /home/ubuntu
git clone https://github.com/giraffeman123/tech-interview-xaldigital.git
cd tech-interview-xaldigital/web-app/
mvn clean package
sudo mv /home/ubuntu/tech-interview-xaldigital/web-app/target/WebApp.war /opt/tomcat/webapps/web-app.war

sudo systemctl restart tomcat


# #nvm installation
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# nvm install --lts
# node -v

# #we clone api repository
# cd /home/ubuntu/
# git clone https://github.com/giraffeman123/k8-api.git
# #cd k8-api/

# #create directory for app logs
# sudo mkdir /var/log/merge-sort-app

# #we add the api as a service unit in systemd service manager 
# cat > /home/ubuntu/merge-sort-app.service <<EOF
# [Unit]
# Description=Simple NodeJs App with merge-sort algorithm and other endpoints for testing
# After=network.target
# [Service]
# ExecStart=/usr/bin/node /home/ubuntu/k8-api/index.js
# WorkingDirectory=/home/ubuntu/k8-api
# Restart=always
# User=ubuntu
# Environment=PATH=/usr/bin:/usr/local/bin
# Environment=NODE_ENV=production
# Environment=PORT=${app_port}
# StandardOutput=file:/var/log/merge-sort-app/logs.log
# StandardError=file:/var/log/merge-sort-app/logs.log
# [Install]
# WantedBy=multi-user.target
# EOF

# sudo mv /home/ubuntu/merge-sort-app.service /etc/systemd/system/

# #create link to nodejs executable
# sudo ln -s "$(which node)" /usr/bin/node

# #we enable the service, start it and check status
# sudo systemctl enable merge-sort-app
# sudo systemctl start merge-sort-app
# sudo systemctl status merge-sort-app

# #install, configure and start cloudwatch agent
# mkdir /tmp/cloudwatch-logs && cd /tmp/cloudwatch-logs
# wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
# sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:${ssm_cloudwatch_config} -s

# #install, configure and start ssm-agent
# sudo mkdir /tmp/ssm && cd /tmp/ssm
# wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
# sudo dpkg -i amazon-ssm-agent.deb
# sudo systemctl enable amazon-ssm-agent
# rm amazon-ssm-agent.deb