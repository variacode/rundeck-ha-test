#!/bin/bash

#exit on error
set -e

#Fix folder permissions
sudo chown -R $USERNAME:$USERNAME $HOME;


#TODO SACAR
echo "######### RUN.SH ######### $RUNDECK_BUNDLE ##### $RUNDECK_ROOT #######"

# Some Cleanup
rm -rfv $HOME/server/logs/*
rm -fv $HOME/testdata/*

# Configure general stuff.
./rdpro-installer configure-server-hostname --server-hostname $RUNDECK_NODE --rdeck-base $HOME
./rdpro-installer configure-server-name --rdeck-base $HOME --server-name $RUNDECK_NODE
./rdpro-installer configure-server-url --server-url $RUNDECK_URL --rdeck-base $HOME

# open permissions via api
rm -f $HOME/etc/apitoken.aclpolicy
cp $HOME/etc/admin.aclpolicy $HOME/etc/apitoken.aclpolicy
sed -i -e "s:admin:api_token_group:" $HOME/etc/apitoken.aclpolicy

# RUN TEST PRESTART SCRIPT
if [[ ! -z "$CONFIG_SCRIPT_PRESTART" && -f $CONFIG_SCRIPT_PRESTART ]];
then
  . $CONFIG_SCRIPT_PRESTART
else
  echo "### Prestart config not set. skipping..."
fi


# PARTY HARD (start rundeck)
./rdpro-installer start --rdeck-base $HOME

# Wait for server to start
LOGFILE=$HOME/server/logs/catalina.out
SUCCESS_MSG="INFO: Server startup in"
MAX_ATTEMPTS=30
SLEEP=10
echo "Waiting for $RUNDECK_NODE to start. This will take about 2 minutes... "
declare -i count=0
while (( count <= MAX_ATTEMPTS ))
do
    if ! grep "${SUCCESS_MSG}" "$LOGFILE"
    then  echo "Still working. hang on..."; # output a progress character.
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
# RUN TEST POSTSTART SCRIPT
if [[ ! -z "$CONFIG_SCRIPT_POSTSTART" && -f $CONFIG_SCRIPT_POSTSTART ]];
then
  . $CONFIG_SCRIPT_POSTSTART
else
  echo "### Post start config not set. skipping..."
fi

### Signal READY
# here we should leave some file in a shared folder to signal that the server is ready. so tests can begin.
touch $HOME/testdata/$RUNDECK_NODE.ready

# Keep alive
tail -F -n100 \
 $HOME/server/logs/catalina.out \
 $HOME/var/logs/rundeck.api.log \
 $HOME/var/logs/rundeck.executions.log \
 $HOME/var/logs/rundeck.jobs.log \
 $HOME/var/logs/rundeck.log \
 $HOME/var/logs/rundeck.options.log \
 $HOME/var/logs/rundeck.storage.log

