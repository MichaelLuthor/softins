#!/bin/sh

# Install the last version of jenkins.
# This script would config all jenkins's data in install location,
# and also, it would generate some helper scripts to manage jeknins.
# @author Michael Luthor <michaelluthor@163.com>

default_install_location=/usr/local/bin/jenkins
read -p "where to install ($default_install_location) : " install_location
if [ "" = "$install_location" ]; then
  install_location=$default_install_location
fi

default_http_port=8080
read -p "which port to run ($default_http_port) : " http_port
if [ "" = "$http_port" ]; then
  http_port=default_http_port
fi

if [ ! -d $install_location ]; then
  mkdir $install_location
fi

echo "start to download last version jenkins..."
wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war --output-document="$install_location/jenkins.war"

echo "build workspace"
mkdir "$install_location/webroot"
mkdir "$install_location/plugins"
mkdir "$install_location/temp"
mkdir "$install_location/lib"

echo "generate start.sh"
echo "#!/bin/sh" >> "$install_location/start.sh"
echo "export JENKINS_HOME=$install_location/home/" >> "$install_location/start.sh"
echo "nohup java -jar jenkins.war --webroot=webroot/ --pluginroot=plugins/ --extractedFilesFolder=temp/ --logfile=jenkins.log --commonLibFolder=lib/ --httpPort=$http_port &" >> "$install_location/start.sh"
chmod u+x "$install_location/start.sh"

echo "generate stop.sh"
echo "#!/bin/sh" >> "$install_location/stop.sh"
echo "kill -9 \`ps -ef | grep jenkins.war | grep -v 'grep' | awk '{print \$2}'\`" >> "$install_location/stop.sh"
chmod u+x "$install_location/stop.sh"

echo "generate purge.sh"
echo "#!/bin/sh" >> "$install_location/purge.sh"
echo "rm -fr $install_location" >> "$install_location/purge.sh"
chmod u+x "$install_location/purge.sh"

echo "done"
