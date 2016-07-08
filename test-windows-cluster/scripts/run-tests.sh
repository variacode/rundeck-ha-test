#!/bin/bash
#
# Main Tests orchestation script
set -e

echo "BEGIN CLUSTER TEST"

#Run stage 1
vagrant ssh -c "/scripts/test-cluster/run-step1.sh" testnode
sleep 3;

# Kill main rundeck instance.
echo "Killing primary node..."
vagrant halt --force rundeck1
sleep 3;

# Trigger active mode on passive node.
echo "Waiting 5 minutes for takeover to take place"
sleep 300;

#Run stage 2
vagrant ssh -c "/scripts/test-cluster/run-step2.sh" testnode
sleep 3;


#Tests OK!
echo "All CLUSTER Tests successfully finished."



