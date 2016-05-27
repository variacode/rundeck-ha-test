#!/bin/bash
# Check we are in correct dir.
SCRIPTFILE=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTFILE")
cd $SCRIPTDIR

# gen TS
TS=`date +%Y%m%d-%H%M%S`

set -ex

# tickle installer for it to rebuild
date > dockers/rundeck/rundeckpro-installer/build_control

# clean up docker env
docker-compose down --volumes --remove-orphans

# re-build docker env
docker-compose build

# run docker
docker-compose up -d

# Wait a little to start tests
sleep 5

# Start tests
scripts/run-tests.sh

# wait after finish
sleep 3

# Stop and clean all
docker-compose down --volumes --remove-orphans



