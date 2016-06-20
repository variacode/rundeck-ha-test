#!/bin/bash
# Check we are in correct dir.
SCRIPTFILE=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTFILE")
cd $SCRIPTDIR

set -ex

# tickle installer for it to rebuild
date > dockers/rundeck/rundeckpro-installer/build_control

# RUN DR TEST
. test-dr/run.sh


