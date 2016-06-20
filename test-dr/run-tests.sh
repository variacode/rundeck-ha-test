#!/bin/bash
#
# Main Tests orchestation script
set -e

echo "Beginning tests"

#Run stage 1
docker-compose -f $DOCKER_COMPOSE_SPEC exec -T --user rundeck testnode scripts/test-dr/run-step1.sh
sleep 3;

# Kill main rundeck instance.
echo "Killing primary node..."
docker-compose -f $DOCKER_COMPOSE_SPEC kill rundeck1
sleep 3;

# Trigger active mode on passive node.
echo "Setting node2 to active mode."
docker-compose -f $DOCKER_COMPOSE_SPEC exec -T --user rundeck rundeck2 ./rrsystem rundeck-system:set-execution-mode --execution-mode active --url http://rundeck2:4440/$RUNDECK_BUNDLE --username admin --password admin
sleep 3;

#Run stage 2
docker-compose -f $DOCKER_COMPOSE_SPEC exec -T --user rundeck testnode scripts/test-dr/run-step2.sh
sleep 3;


#Tests OK!
echo "All Tests successfully finished."



