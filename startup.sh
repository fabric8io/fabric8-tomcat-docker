#!/bin/sh

echo Welcome to fabric8: http://fabric8.io/
echo
echo Starting Fabric8 container: $FABRIC8_KARAF_NAME 
echo Connecting to ZooKeeper: $FABRIC8_ZOOKEEPER_URL using environment: $FABRIC8_FABRIC_ENVIRONMENT
echo Using bindaddress: $FABRIC8_BINDADDRESS

# TODO allow this to be disabled via an env var
service sshd start

# TODO if enabled should we tail the karaf log to work nicer with docker logs?
#tail -f /home/fabric8/logs/karaf.log

#sudo -u fabric8 /home/fabric8/fabric8-tomcat/bin/fabric8 run
/home/fabric8/fabric8-tomcat/bin/fabric8 run
