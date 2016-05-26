#!/bin/bash

#
# DR TESTS STAGE 2 - Tests after rundeck1 down.
echo "Begin Test Stage 2"

DIR=$(cd `dirname $0` && pwd)
source $DIR/include.sh

# Set exit on error
set -e

#Config

TESTNODE_IP=192.168.234.2
RUNDECK1_ADDR=192.168.234.11
RUNDECK1_PORT=4443
RUNDECK2_ADDR=192.168.234.12
RUNDECK2_PORT=4443

sleep 3
# Check Rundeck 1 Not Responging
## echo -n "Check primary node is not responding... "
## if curl -m5 -sSfk https://$RUNDECK1_ADDR:$RUNDECK1_PORT/rundeckpro-dr
## then
##     echo "Primary node still answering. test failed."
##     exit 1;
## else
##     echo "Primary rundeck down. :)"
## fi

# Check Rundeck 2 Responding
echo -n "Check node 2 still answering... "
curl -sSfk -m5 https://$RUNDECK2_ADDR:$RUNDECK2_PORT/rundeckpro-dr
echo "OK"

echo "sleeping 50 seconds for rundeck2 to write some files"
sleep 50

login
disable_execution
delete_job

# Check Rundeck 2 Working.
# TODO Check that the test job created on node 1 is NOT working
# TODO Check that the test job created on node 2 is working correctly


# Release Resources.
echo "Stage 2 Tests OK..."
exit 0
