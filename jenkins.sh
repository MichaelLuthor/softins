#!/bin/sh

# Install the last version of jenkins.
# This script would config all jenkins's data in install location,
# and also, it would generate some helper scripts to manage jeknins.
# @author Michael Luthor <michaelluthor@163.com>

source include/common.sh

default_install_location=/usr/local/bin/jenkins
default_http_port=8080
java_command=java

install_software () {
  yum install $1
}

export LANG=en_US.UTF-8
read -p "where to install ($default_install_location) : " install_location
if [ "" = "$install_location" ]; then
  install_location=$default_install_location
fi

read -p "which port to run ($default_http_port) : " http_port
if [ "" = "$http_port" ]; then
  http_port=$default_http_port
fi

if [ ! -d $install_location ]; then
  mkdir $install_location
fi

# check java and try to install to local
if ! command -v java >/dev/null 2>&1 ; then
  download java.tar.gz http://javadl.oracle.com/webapps/download/AutoDL?BundleId=227542_e758a0de34e24606bca991d704f6dcbf
  tar -xvf java.tar.gz
  mv jre* jre
  cp -rv jre $install_location
  java_command=$install_location/jre/bin/java
  rm -fr jre java.tar.gz 
fi

# download jenkins.
download jenkins.war http://mirrors.jenkins.io/war-stable/latest/jenkins.war
mv jenkins.war $install_location/jenkins.war

message "build workspace"
mkdir "$install_location/webroot"
mkdir "$install_location/plugins"
mkdir "$install_location/temp"
mkdir "$install_location/lib"

echo "#!/bin/sh" >> "$install_location/start.sh"
echo "export JENKINS_HOME=$install_location/home/" >> "$install_location/start.sh"
echo "nohup $java_command -jar jenkins.war --webroot=webroot/ --pluginroot=plugins/ --extractedFilesFolder=temp/ --logfile=jenkins.log --commonLibFolder=lib/ --httpPort=$http_port &" >> "$install_location/start.sh"
chmod u+x "$install_location/start.sh"

echo "#!/bin/sh" >> "$install_location/stop.sh"
echo "kill -9 \`ps -ef | grep jenkins.war | grep -v 'grep' | awk '{print \$2}'\`" >> "$install_location/stop.sh"
chmod u+x "$install_location/stop.sh"

echo "#!/bin/sh" >> "$install_location/purge.sh"
echo "rm -fr $install_location" >> "$install_location/purge.sh"
chmod u+x "$install_location/purge.sh"

echo "done"
