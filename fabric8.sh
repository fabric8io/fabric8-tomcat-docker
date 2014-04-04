#!/usr/bin/env bash

echo "Starting the fabric8 tomcat container"
docker run -p 8080 -p 22 -d -t fabric8:fabric8-tomcat
