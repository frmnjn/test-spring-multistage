#!/bin/bash
java -Duser.timezone=Indonesia/Jakarta -jar /app.jar --spring.config.location=/data/application.yml app.jar &
envoy -c /etc/service-envoy.yaml --service-cluster service${SERVICE_NAME}