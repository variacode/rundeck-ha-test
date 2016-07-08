#!/bin/bash

set -ex

#load config
. metadata

# clean up test env
rm -rf testdata/* tmp

#Create shared resource folders.
mkdir -p  testdata/resources/cluster \
          testdata/resources/heartbeat \
          testdata/utils \
          testdata/rundeck1 \
          testdata/rundeck2 \
          testdata/resources \
          testdata/rundeckprologs

vagrant destroy --force

# re-build docker env
scripts/prepare-test-env.sh

# init machines.
vagrant up

# Start tests
scripts/run-tests.sh

# wait after finish
sleep 3

# Stop and clean all
#vagrant destroy --force
#rm -rf testdata/* tmp



