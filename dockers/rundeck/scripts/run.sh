#!/bin/bash

#Fix folder permissions
sudo chown -R $USERNAME:$USERNAME $HOME;

# Some Cleanup
rm -rfv $HOME/server/logs/*
rm -fv $HOME/testdata/$RUNDECK_NODE.ready

# Configure general stuff.
./rdpro-installer configure-server-hostname --server-hostname $RUNDECK_NODE --rdeck-base $HOME
./rdpro-installer configure-server-name --rdeck-base $HOME --server-name $RUNDECK_NODE
./rdpro-installer configure-server-url --server-url "" --rdeck-base $HOME
#./rdpro-installer configure-server-url --server-url $RUNDECK_URL --rdeck-base $HOME


# Configure passive mode if applies.
if [[ X$RUNDECK_ROLE == 'Xpassive' ]] ;
then
    echo "This is the passive instance. Configuring passive Node";
    ./rdpro-installer configure-execution-mode --rdeck-base $HOME --execution-mode passive;
    # Here all instructions to run in the passive pre-start
else
    echo "This is the active Instance";
    # Here all instructions to run in the active pre-start
fi

# PARTY HARD
./rdpro-installer start --rdeck-base $HOME

# Wait for server to start
LOGFILE=$HOME/server/logs/catalina.out
SUCCESS_MSG="INFO: Server startup in"
MAX_ATTEMPTS=18
SLEEP=10
echo "waiting for $RUNDECK_NODE to start"
declare -i count=0
while (( count <= MAX_ATTEMPTS ))
do
    if ! grep "${SUCCESS_MSG}" "$LOGFILE"
    then  echo -n "."; # output a progress character.
    else  break; # found successful startup message.
    fi
    (( count += 1 ))  ; # increment attempts counter.
    (( count == MAX_ATTEMPTS )) && {
        echo >&2 "FAIL: Reached max attempts to find success message in catalina.out. Exiting."
        exit 1
    }
    sleep $SLEEP; # wait before trying again.
done
echo "RUNDECK NODE $RUNDECK_NODE started successfully!!"


### POST CONFIG

# Create Replication Jobs and API Tokens.
if [[ X$RUNDECK_ROLE == 'Xpassive' ]] ;
then
    echo "Post configuring passive instance";
    # Here all instructions to run in the passive post-start

else
    echo "Post configuring active instance";
    # Here all instructions to run in the active post-start

    # Request apitoken from server 2 (use rrtokens)
    # Configure JobReplication Plugin
    # Configure Execution Replication Plugin

fi

### Signal READY
# here we should leave some file in a shared folder to signal that the server is ready. so tests can begin.
touch $HOME/testdata/$RUNDECK_NODE.ready

# Keep alive
tail -F $HOME/server/logs/catalina.out
