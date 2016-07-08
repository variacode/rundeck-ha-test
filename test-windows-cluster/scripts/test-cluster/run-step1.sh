#!/bin/bash
#
# CLUSTER TESTS STAGE 1 - Tests before rundeck1 down.
echo "Begin Cluster Test Step 1 (before fail)"

WORKDIR=/testdata
CONFDIR=$HOME/config

RUNDECK1_URL="http://rundeck1:8080/rundeckpro"
RUNDECK2_URL="http://rundeck2:8080/rundeckpro"

#BEGIN TEST

# Set exit on error
set -e

#Config

# Check  Pings
echo "Check server pings"
ping -qc3 rundeck1
ping -qc3 rundeck2

# Check Rundeck answering in both machines
echo -en "\nCheck rundecks answering... "
curl -sSfk -m5 $RUNDECK1_URL
curl -sSfk -m5 $RUNDECK2_URL
echo "OK"

echo "Sleeping 2 minutes so we get some jobs to run"
sleep 120

# Check Rundeck 1 Working.
# Check that the test job created on node 1 is working correctly
echo -n "Check Node 1 working... "
test 0 -lt $(find $WORKDIR/rundeck1 -mmin -0.5 -regex '.*jobresult-r1.txt' | wc -l)
echo "OK"

# Check that the test job created on node 2 is working correctly
echo -n "Check Node 2 working... "
test 0 -lt $(find $WORKDIR/rundeck2 -mmin -0.5 -regex '.*jobresult-r2.txt' | wc -l)
echo "OK"

# Check for erroneous takeovers
echo -n "Check we don't have takeovers from node 1... "
test 0 -eq $(find $WORKDIR/rundeck1 -mmin -0.5 -regex '.*jobresult-r2.txt' | wc -l)
echo "OK"

echo -n "Check we don't have takeovers from node 2... "
test 0 -eq $(find $WORKDIR/rundeck2 -mmin -0.5 -regex '.*jobresult-r1.txt' | wc -l)
echo "OK"

# Release Resources.
echo "Cluster Tests Step 1 OK..."
exit 0
