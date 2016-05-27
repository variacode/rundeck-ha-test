#!/bin/bash
#
# DR TESTS STAGE 2 - Tests before rundeck1 down.
echo "Begin Test Stage 1"

#DIR=$(cd `dirname $0` && pwd)
#source $DIR/include.sh

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

# Check  Pings
echo "Check server pings"
#ping -c3 $TESTNODE_IP
ping -c3 rundeck1
ping -c3 rundeck2


# Check Rundeck answering in both machines
echo -n "Check rundecks answering... "
curl -sSfk -m5 http://rundeck1:4440/rundeckpro-dr
curl -sSfk -m5 http://rundeck2:4440/rundeckpro-dr
echo "OK"

echo "sleeping a minute so we get some files to write"
sleep 60

# Check Rundeck 1 Working.
# TODO Check that the test job created on node 1 is working correctly
echo "RUNDECK 1: $(find . -mmin -0.5 -regex '.*rundeck1_[0-9].+' | wc -l) files."

# TODO Check that the test job created on node 2 is NOT working
echo "RUNDECK 2: $(find . -mmin -0.5 -regex '.*rundeck2_[0-9].+' | wc -l) files."

# Release Resources.
echo "Stage 1 Tests OK..."
exit 0
