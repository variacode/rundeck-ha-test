#!/bin/bash
#
# Main Tests orchestation script
set -e

echo "Beginning tests"

#Run stage 1
docker-compose exec --user rundeck testnode ./run-step1.sh
sleep 3;

# Kill main rundeck instance.
docker-compose kill rundeck1
sleep 3;

#Run stage 2
docker-compose exec --user rundeck testnode ./run-step2.sh
sleep 3;


#Tests OK!
echo "Tests successfully finished."
exit 0;


