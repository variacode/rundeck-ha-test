#!/bin/bash

export DOCKER_COMPOSE_SPEC=docker-compose-test-dr.yml

#Bundle to use on this test.
export RUNDECK_BUNDLE=rundeckpro-dr

set -e

# tickle installer for it to rebuild
#date > dockers/rundeck/rundeckpro-installer/build_control

# clean up docker env
docker-compose -f $DOCKER_COMPOSE_SPEC down --volumes --remove-orphans

# re-build docker env
docker-compose -f $DOCKER_COMPOSE_SPEC build

# run docker
docker-compose -f $DOCKER_COMPOSE_SPEC up -d

# Wait a little to start tests
sleep 5

# Start tests
. test-dr/run-tests.sh

# wait after finish
sleep 3

# Stop and clean all
docker-compose -f $DOCKER_COMPOSE_SPEC down --volumes --remove-orphans



