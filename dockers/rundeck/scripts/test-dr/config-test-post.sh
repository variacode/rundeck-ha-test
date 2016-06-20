#!/bin/bash
#### DR TEST CONFIGURATION.
echo "DR test post config"


# Request apitoken for servers
TOKEN_R1=$($HOME/rrtokens rundeck-apitokens:create --token-user admin --url http://rundeck1:4440/$RUNDECK_ROOT --username admin --password admin)
TOKEN_R2=$($HOME/rrtokens rundeck-apitokens:create --token-user admin --url http://rundeck2:4440/$RUNDECK_ROOT --username admin --password admin)


# Create Replication Jobs and API Tokens.
if [[ X$RUNDECK_ROLE == 'Xpassive' ]] ;
then
    echo "Post configuring passive instance";
    # Here all instructions to run in the passive post-start

    # delete and create project
    curl -sS -H "X-Rundeck-Auth-Token: $TOKEN_R2" \
        -H "Accept: application/json" \
        -X DELETE http://rundeck2:4440/$RUNDECK_ROOT/api/11/project/testproject \
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
    }' http://rundeck2:4440/$RUNDECK_ROOT/api/11/projects

else
    echo "Post configuring active instance";
    # Here all instructions to run in the active post-start

    #Create project
    curl -sS -H "X-Rundeck-Auth-Token: $TOKEN_R1" \
        -H "Accept: application/json" \
        -X DELETE http://rundeck1:4440/$RUNDECK_ROOT/api/11/project/testproject \
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
    }' http://rundeck1:4440/$RUNDECK_ROOT/api/11/projects


    # Configure JobReplication Plugin
    echo "Configuring job replication for testproject."
    curl -sSf -H "X-Rundeck-Auth-Token: $TOKEN_R1" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
      "config": {
        "apiToken": "'"$TOKEN_R2"'",
        "url": "http://rundeck2:4440/'$RUNDECK_ROOT'",
        "project": "${job.project}"
      }
    }' http://rundeck1:4440/$RUNDECK_ROOT/api/17/project/testproject/scm/export/plugin/rundeckpro-job-replication-export/setup

    # TODO Configure Execution Replication Plugin (logstore-replication plugin)

    #Create a test job which creates some file on a shared storage or do something stupid and easily detectable.($HOME/testdata)
    sleep 5
    echo "Creating test job"
    curl -sSf -H "X-Rundeck-Auth-Token: $TOKEN_R1" -F xmlBatch=@$HOME/config/test-dr/job.xml http://rundeck1:4440/$RUNDECK_ROOT/api/17/jobs/import?project=testproject

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

