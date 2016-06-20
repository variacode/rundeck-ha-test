#!/bin/bash

#
# CLUSTER TESTS STAGE 2 - Tests after rundeck1 down.
echo "Begin Cluster Test Step 2 (after fail)"

#DIR=$(cd `dirname $0` && pwd)
#source $DIR/include.sh

# Set exit on error
set -e

sleep 3
# Check Rundeck 1 Not Responging
echo -n "Check primary node is not responding... "
if curl -m5 -sSfk http://rundeck1:4440/$RUNDECK_ROOT
then
    echo "Primary node still answering. test failed."
    exit 1;
else
    echo "Primary rundeck down. :)"
fi

# Check Rundeck 2 Responding
echo -n "Check node 2 still answering... "
curl -sSfk -m5 http://rundeck2:4440/$RUNDECK_ROOT
echo "OK"

echo "Waiting one more minute for rundeck2 to run some jobs..."
sleep 60


# Check Rundeck 1 NOT Working.
# Check that the test job created on node 1 is not working correctly
echo -n "Check Node 1 not working... "
test 0 -eq $(find . -mmin -0.5 -regex '.*host-rundeck1_node-rundeck1_[0-9].+' | wc -l)
echo "OK"

# Check that the test job created on node 2 is working correctly
echo -n "Check Node 2 working... "
test 0 -lt $(find . -mmin -0.5 -regex '.*host-rundeck2_node-rundeck2_[0-9].+' | wc -l)
echo "OK"

# Check node 2 took over jobs from node 1
echo -n "Check Node 2 took over correctly... "
test 0 -lt $(find . -mmin -0.5 -regex '.*host-rundeck2_node-rundeck1_[0-9].+' | wc -l)
echo "OK"

# Check for erroneous cases
echo -n "Check we don't have takeovers and executions from node 1 (just to be sure)... "
test 0 -eq $(find . -mmin -0.5 -regex '.*host-rundeck1_node-rundeck2_[0-9].+' | wc -l)
echo "OK"

# this is exhausting, get some rest
sleep 2

# Release Resources.
echo "Cluster Tests Step 2 OK..."

exit 0
