#!/bin/bash

#exit on error
set -e

#Fix folder permissions
sudo chown -R $USERNAME:$USERNAME $HOME;

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


# Configure passive mode if applies.
if [[ X$RUNDECK_ROLE == 'Xpassive' ]] ;
then
    # Here all instructions to run in the passive pre-start
    echo "This is the passive instance. Configuring passive Node";
    ./rdpro-installer configure-execution-mode --rdeck-base $HOME --execution-mode passive;

else
    # Here all instructions to run in the active pre-start
    echo "This is the active Instance";

fi

# PARTY HARD
./rdpro-installer start --rdeck-base $HOME

# Wait for server to start
LOGFILE=$HOME/server/logs/catalina.out
SUCCESS_MSG="INFO: Server startup in"
MAX_ATTEMPTS=18
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

# Request apitoken for servers
TOKEN_R1=$($HOME/rrtokens rundeck-apitokens:create --token-user admin --url http://rundeck1:4440/rundeckpro-dr --username admin --password admin)
TOKEN_R2=$($HOME/rrtokens rundeck-apitokens:create --token-user admin --url http://rundeck2:4440/rundeckpro-dr --username admin --password admin)

# Create Replication Jobs and API Tokens.
if [[ X$RUNDECK_ROLE == 'Xpassive' ]] ;
then
    echo "Post configuring passive instance";
    # Here all instructions to run in the passive post-start

    # delete and create project
    curl -sS -H "X-Rundeck-Auth-Token: $TOKEN_R2" \
        -H "Accept: application/json" \
        -X DELETE http://rundeck2:4440/rundeckpro-dr/api/11/project/testproject \
        || true

    echo "Creating project"
    curl -sSf -H "X-Rundeck-Auth-Token: $TOKEN_R2" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
      "name": "testproject",
      "description": "",
      "config": {
        "resources.source.1.config.file": "/home/rundeck/projects/testproject/etc/resources.xml",
        "resources.source.1.config.format": "resourcexml",
        "project.nodeCache.delay": "30",
        "service.FileCopier.default.provider": "stub",
        "service.NodeExecutor.default.provider": "stub",
        "resources.source.1.config.includeServerNode": "true",
        "project.nodeCache.enabled": "true",
        "resources.source.1.config.requireFileExists": "false",
        "project.name": "testproject",
        "resources.source.1.config.generateFileAutomatically": "true",
        "resources.source.1.type": "file"
      }
    }' http://rundeck2:4440/rundeckpro-dr/api/11/projects

else
    echo "Post configuring active instance";
    # Here all instructions to run in the active post-start

    #Create project
    curl -sS -H "X-Rundeck-Auth-Token: $TOKEN_R1" \
        -H "Accept: application/json" \
        -X DELETE http://rundeck1:4440/rundeckpro-dr/api/11/project/testproject \
        || true

    echo "Creating project"
    curl -sSf -H "X-Rundeck-Auth-Token: $TOKEN_R1" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
      "name": "testproject",
      "description": "",
      "config": {
        "resources.source.1.config.file": "/home/rundeck/projects/testproject/etc/resources.xml",
        "resources.source.1.config.format": "resourcexml",
        "project.nodeCache.delay": "30",
        "service.FileCopier.default.provider": "stub",
        "service.NodeExecutor.default.provider": "stub",
        "resources.source.1.config.includeServerNode": "true",
        "project.nodeCache.enabled": "true",
        "resources.source.1.config.requireFileExists": "false",
        "project.name": "testproject",
        "resources.source.1.config.generateFileAutomatically": "true",
        "resources.source.1.type": "file"
      }
    }' http://rundeck1:4440/rundeckpro-dr/api/11/projects


    # Configure JobReplication Plugin
    echo "Configuring job replication for testproject."
    curl -sSf -H "X-Rundeck-Auth-Token: $TOKEN_R1" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
      "config": {
        "apiToken": "'"$TOKEN_R2"'",
        "url": "http://rundeck2:4440/rundeckpro-dr",
        "project": "${job.project}"
      }
    }' http://rundeck1:4440/rundeckpro-dr/api/17/project/testproject/scm/export/plugin/rundeckpro-job-replication-export/setup

    # TODO Configure Execution Replication Plugin (logstore-replication plugin)

    #Create a test job which creates some file on a shared storage or do something stupid and easily detectable.($HOME/testdata)
    sleep 5
    echo "Creating test job"
    curl -sSf -H "X-Rundeck-Auth-Token: $TOKEN_R1" -F xmlBatch=@$HOME/xmls/job.xml http://rundeck1:4440/rundeckpro-dr/api/17/jobs/import?project=testproject

fi

### Signal READY
# here we should leave some file in a shared folder to signal that the server is ready. so tests can begin.
touch $HOME/testdata/$RUNDECK_NODE.ready

# Keep alive
tail -F $HOME/server/logs/catalina.out \
 $HOME/var/logs/rundeck.api.log \
 $HOME/var/logs/rundeck.executions.log \
 $HOME/var/logs/rundeck.jobs.log \
 $HOME/var/logs/rundeck.log \
 $HOME/var/logs/rundeck.options.log \
 $HOME/var/logs/rundeck.storage.log

