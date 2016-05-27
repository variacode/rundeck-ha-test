#!/bin/bash

#
# DR TESTS STAGE 2 - Tests after rundeck1 down.
echo "Begin Test Stage 2"

#DIR=$(cd `dirname $0` && pwd)
#source $DIR/include.sh

# Set exit on error
set -e

sleep 3
# Check Rundeck 1 Not Responging
echo -n "Check primary node is not responding... "
if curl -m3 -sSfk http://rundeck1:4440/rundeckpro-dr
then
    echo "Primary node still answering. test failed."
    exit 1;
else
    echo "Primary rundeck down. :)"
fi

# Check Rundeck 2 Responding
echo -n "Check node 2 still answering... "
curl -sSfk -m5 http://rundeck2:4440/rundeckpro-dr
echo "OK"

echo "sleeping 50 seconds for rundeck2 to write some files"
sleep 60

#login
#disable_execution
#delete_job

# Check Rundeck 2 Working.
# TODO Check that the test job created on node 1 is NOT working
echo "RUNDECK 1: $(find . -mmin -0.5 -regex '.*rundeck1_[0-9].+' | wc -l) files."

# TODO Check that the test job created on node 2 is working correctly
echo "RUNDECK 2: $(find . -mmin -0.5 -regex '.*rundeck2_[0-9].+' | wc -l) files."


# Release Resources.
echo "Stage 2 Tests OK..."
exit 0
