#!/bin/bash
#
# DR TESTS STAGE 2 - Tests after rundeck1 down.

# Set exit on error
set -e

#Config

TESTNODE_IP=192.168.234.2
RUNDECK1_ADDR=192.168.234.11
RUNDECK1_PORT=4443
RUNDECK2_ADDR=192.168.234.12
RUNDECK2_PORT=4443

sleep 3
# Check Rundeck 1 Not Responging
if curl -m10 -sSf http://$RUNDECK1_ADDR:$RUNDECK1_PORT
then
    echo "Primary still responging. test failed."
    exit 1;
else
    echo "Primary rundeck down. :)"
fi

# Check Rundeck 2 Responding
curl -sSfk -m5 https://$RUNDECK2_ADDR:$RUNDECK2_PORT/rundeckpro-dr > /dev/null

# Check Rundeck 2 Working.



# Release Resources.
echo "Test Step 1 OK"
exit 0
