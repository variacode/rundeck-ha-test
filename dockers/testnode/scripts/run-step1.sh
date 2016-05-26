#!/bin/bash
#
# DR TESTS STAGE 2 - Tests before rundeck1 down.
echo "Begin Test Stage 1"

DIR=$(cd `dirname $0` && pwd)
source $DIR/include.sh

# Wait for node 1 and 2 ready.
MAX_ATTEMPTS=20
SLEEP=10
echo "Waiting for nodes to start"
declare -i count=0
while (( count <= MAX_ATTEMPTS ))
do
    if [[ -f $HOME/testdata/rundeck1.ready && -f $HOME/testdata/rundeck2.ready ]]
    then
        break;
    else
        echo -n "."; # output a progress character.
    fi
    (( count += 1 ))  ; # increment attempts counter.
    (( count == MAX_ATTEMPTS )) && {
        echo >&2 "FAIL: Reached max attempts waiting for rundeck nodes. Exiting."
        exit 1
    }
    sleep $SLEEP; # wait before trying again.
done
echo -e "\n\nRundeck Nodes READY. Beginning tests..."

#BEGIN TEST

# Set exit on error
set -e

#Config

TESTNODE_IP=192.168.234.2
RUNDECK1_ADDR=192.168.234.11
RUNDECK1_PORT=4443
RUNDECK2_ADDR=192.168.234.12
RUNDECK2_PORT=4443

# Check  Pings
echo "Check server pings"
#ping -c3 $TESTNODE_IP
ping -c3 $RUNDECK1_ADDR
ping -c3 $RUNDECK2_ADDR


# Check Rundeck answering in both machines
echo -n "Check rundecks answering... "
curl -sSfk -m5 https://$RUNDECK1_ADDR:$RUNDECK1_PORT/rundeckpro-dr
curl -sSfk -m5 https://$RUNDECK2_ADDR:$RUNDECK2_PORT/rundeckpro-dr
echo "OK"

# clears previous test data and imports default job
clean

login
import_job_to_project

echo "sleeping 50 seconds so we get some files to write"
sleep 50

# Check Rundeck 1 Working.
# TODO Check that the test job created on node 1 is working correctly
# TODO Check that the test job created on node 2 is NOT working


# Release Resources.
echo "Stage 1 Tests OK..."
exit 0
