#!/bin/bash
set -ex

TESTNODE_IP=192.168.234.2
RUNDECK1_ADDR=192.168.234.11
RUNDECK1_PORT=4443
RUNDECK2_ADDR=192.168.234.12
RUNDECK2_PORT=4443

# Check  Pings
echo "Check server pings"
#ping -c3 $TESTNODE_IP
ping -c3 $RUNDECK1_ADDR
ping -c3 $RUNDECK2_ADDR


# Check Rundeck answering in both machines
echo "Check rundeck answering"
curl -sSfk -m5 https://$RUNDECK1_ADDR:$RUNDECK1_PORT/rundeckpro-dr > /dev/null
curl -sSfk -m5 https://$RUNDECK2_ADDR:$RUNDECK2_PORT/rundeckpro-dr > /dev/null


# Check Rundeck 1 Working.

# Kill Primary Rundeck
echo "skipping killing of primary machine."
docker-compose kill rundeck1

sleep 3
# Check Rundeck 1 Not Responging
#curl -sSf http://$RUNDECK1_ADDR:$RUNDECK1_PORT > /dev/null

# Check Rundeck 2 Responding
curl -sSfk -m5 https://$RUNDECK2_ADDR:$RUNDECK2_PORT/rundeckpro-dr > /dev/null

# Check Rundeck 2 Working.


# Release Resources.
echo "Tests OK"
exit 0
