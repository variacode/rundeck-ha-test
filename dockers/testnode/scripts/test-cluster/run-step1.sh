#!/bin/bash
#
# CLUSTER TESTS STAGE 1 - Tests before rundeck1 down.
echo "Begin Cluster Test Step 1 (before fail)"

#DIR=$(cd `dirname $0` && pwd)
#source $DIR/include.sh

# Wait for node 1 and 2 ready.
MAX_ATTEMPTS=30
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
# Give 5 more seconds so nodes settle down their config and resources.
sleep 5
echo -e "\n\nRundeck Nodes READY. Beginning tests..."

#BEGIN TEST

# Set exit on error
set -e

#Config

# Check  Pings
echo "Check server pings"
#ping -c3 $TESTNODE_IP
ping -qc3 rundeck1
ping -qc3 rundeck2


# Check Rundeck answering in both machines
echo -en "\nCheck rundecks answering... "
curl -sSfk -m5 http://rundeck1:4440/$RUNDECK_ROOT
curl -sSfk -m5 http://rundeck2:4440/$RUNDECK_ROOT
echo "OK"

echo "Sleeping two minutes so we get some files to write"
sleep 120

# Check Rundeck 1 Working.
# Check that the test job created on node 1 is working correctly
echo -n "Check Node 1 working... "
test 0 -lt $(find . -mmin -0.5 -regex '.*host-rundeck1_node-rundeck1_[0-9].+' | wc -l)
echo "OK"

# Check that the test job created on node 2 is working correctly
echo -n "Check Node 2 working... "
test 0 -lt $(find . -mmin -0.5 -regex '.*host-rundeck2_node-rundeck2_[0-9].+' | wc -l)
echo "OK"

# Check for erroneous takeovers
echo -n "Check we don't have takeovers from node 1... "
test 0 -eq $(find . -mmin -0.5 -regex '.*host-rundeck1_node-rundeck2_[0-9].+' | wc -l)
echo "OK"

echo -n "Check we don't have takeovers from node 2... "
test 0 -eq $(find . -mmin -0.5 -regex '.*host-rundeck2_node-rundeck1_[0-9].+' | wc -l)
echo "OK"

# Release Resources.
echo "Cluster Tests Step 1 OK..."
exit 0
