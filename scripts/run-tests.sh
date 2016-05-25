#!/bin/bash
#
# Main Tests orchestation script
set -e

echo "Beginning tests"

#Run stage 1
docker-compose exec --user rundeck testnode ./run-step1.sh
sleep 3;

# Kill main rundeck instance.
echo "Killing primary node..."
docker-compose kill rundeck1
sleep 3;

# Trigger active mode on passive node.
echo "Setting node2 to active mode."
docker-compose exec --user rundeck rundeck2 ./rrsystem rundeck-system:set-execution-mode --execution-mode active --url https://rundeck2:4443/rundeckpro-dr --username admin --password admin
sleep 3;

#Run stage 2
docker-compose exec --user rundeck testnode ./run-step2.sh
sleep 3;


#Tests OK!
echo "All Tests successfully finished."
exit 0;


