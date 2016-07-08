#!/bin/bash
# Check we are in correct dir.
cd $(dirname "$0")


set -e

# poke installer to force docker to rebuild it.
date > dockers/rundeck/rundeckpro-installer/build_control

# RUN DR TEST
test-dr/run.sh

#Run Cluster Test
test-cluster/run.sh

#Run Cluster Windows
test-windows-cluster/run.sh



