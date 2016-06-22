#!/bin/bash
# Check we are in correct dir.
SCRIPTFILE=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTFILE")
cd $SCRIPTDIR

set -e

# poke installer to force docker to rebuild it.
date > dockers/rundeck/rundeckpro-installer/build_control

# RUN DR TEST
test-dr/run.sh

#Run Cluster Test
test-cluster/run.sh




