#!/bin/sh

./rdpro-installer install-all \
  --java-opts "-Djava.security.egd=file:/dev/./urandom" \
  --http-port ${PORT} \
  --server-hostname ${RUNDECK_NODE} \
  --server-url "http://${RUNDECK_NODE}:${PORT}/rundeckpro-team"

./rdpro-installer start --rdeck-base ${HOME} \
  && tail -F ${HOME}/server/logs/catalina.out


