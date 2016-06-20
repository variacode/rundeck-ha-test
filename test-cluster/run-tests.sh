#!/bin/bash
#
# Main Tests orchestation script
set -e

echo "BEGIN CLUSTER TEST"

#Run stage 1
docker-compose -f $DOCKER_COMPOSE_SPEC exec -T --user rundeck testnode scripts/test-cluster/run-step1.sh
sleep 3;

# Kill main rundeck instance.
echo "Killing primary node..."
docker-compose -f $DOCKER_COMPOSE_SPEC kill -s9 rundeck1
sleep 3;

# Trigger active mode on passive node.
echo "Waiting 2 minutes for takeover to take place"
sleep 120;

#Run stage 2
docker-compose -f $DOCKER_COMPOSE_SPEC exec -T --user rundeck testnode scripts/test-cluster/run-step2.sh
sleep 3;


#Tests OK!
echo "All CLUSTER Tests successfully finished."



