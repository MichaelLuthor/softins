#!/bin/bash
SCRIPT_FOLDER=$(dirname $(readlink -f "$0"))
source $SCRIPT_FOLDER/jenkins.manager.config

jenkins_start () {
  pid=`ps -ef | grep jenkins.war | grep -v 'grep' | awk '{print $2}'`
  if [ "" != "$pid" ]; then
    echo "jenkins already started"
    exit
  fi 

  echo "starting jenkins..."
  cd $install_location
  export JENKINS_HOME=$install_location/home/
  nohup $java_command -jar jenkins.war \
    --webroot=webroot/ \
    --pluginroot=plugins/ \
    --extractedFilesFolder=temp/ \
    --logfile=jenkins.log \
    --commonLibFolder=lib/ \
    --httpPort=$http_port \
    &
  
  pid=`ps -ef | grep jenkins.war | grep -v 'grep' | awk '{print $2}'`
  echo "$pid" > $install_location/jenkins.pid
  echo "jenkins started, PID=$pid"
}

jenkins_stop () {
  echo "stoping jenkins..."
  pid=`ps -ef | grep jenkins.war | grep -v 'grep' | awk '{print \$2}'`
  if [ "" == "$pid" ]; then
    echo "jenkins has not been started."
    exit
  fi
  kill -9 $pid
  rm -f $install_location/jenkins.pid
  echo "jenkins stoped"
}

jenkins_uninstall () {
  echo "uninstalling jenkins ..."
  rm -fr $install_location
  rm -f /usr/bin/jenkins.manager
  echo "jenkins uninstalled"
}

case $1 in
start)
  jenkins_start
  ;;
stop)
  jenkins_stop
  ;;
restart)
  jenkins_stop
  jenkins_start
  ;;
uninstall)
  jenkins_uninstall
  ;;
*)
  echo "Commands : start stop restart uninstall"
  exit
  ;;
esac
