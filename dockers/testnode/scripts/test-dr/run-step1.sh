#!/bin/bash
#
# DR TESTS STAGE 2 - Tests before rundeck1 down.
echo "Begin Test Stage 1"

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

echo "sleeping a minute so we get some files to write"
sleep 60

# Check Rundeck 1 Working.
# Check that the test job created on node 1 is working correctly
echo -n "Check Node 1 working... "
test 0 -lt $(find . -mmin -0.5 -regex '.*rundeck1_[0-9].+' | wc -l)
echo "OK"

#Check that the test job created on node 2 is NOT working
echo -n "Check Node 2 not working... "
test 0 -eq $(find . -mmin -0.5 -regex '.*rundeck2_[0-9].+' | wc -l)
echo "OK"

# Release Resources.
echo "Stage 1 Tests OK..."
exit 0
