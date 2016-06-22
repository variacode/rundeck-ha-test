#!/bin/bash
# Check we are in correct dir.
SCRIPTFILE=$(readlink -f "$0")
SCRIPTDIR=$(dirname "$SCRIPTFILE")
cd $SCRIPTDIR

set -x

docker-compose -f docker-compose-test-cluster.yml down --volumes --remove-orphans
docker-compose -f docker-compose-test-dr.yml down --volumes --remove-orphans




