#!/bin/bash

# Check env
if [[ ! $PORT ]] ; then PORT=4440 ; fi
if [[ ! $RUNDECK_NODE ]] ; then RUNDECK_NODE=rundeck1 ; fi

./rdpro-installer install-all \
  --java-opts "-Djava.security.egd=file:/dev/./urandom" \
  --http-port $PORT \
  --server-hostname $RUNDECK_NODE \
  --server-url "http://$RUNDECK_NODE:$PORT/rundeckpro-dr"

./rdpro-installer start --rdeck-base $HOME \
  && tail -F $HOME/server/logs/catalina.out
