#!/bin/bash
#### Cluster TEST CONFIGURATION (After rundeck start)
echo "CLUSTER test post config"


# Request apitoken for servers
echo "Requesting API token..."
APITOKEN=$($HOME/rrtokens rundeck-apitokens:create --token-user admin --url http://$RUNDECK_NODE:4440/$RUNDECK_ROOT --username admin --password admin)
#TOKEN_R2=$($HOME/rrtokens rundeck-apitokens:create --token-user admin --url http://rundeck2:4440/$RUNDECK_ROOT --username admin --password admin)

if [[ X$RUNDECK_ROLE == 'Xleader' ]] ; then

  # Create project on the leader node.
  echo "Creating project"
  curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
    "name": "PRO_HA",
    "description": "",
    "config": {
      "project.description" : "",
      "project.name" : "PRO_HA",
      "project.nodeCache.delay" : "30",
      "project.nodeCache.enabled" : "true",
      "resources.source.1.config.file" : "projects/etc/resources.xml",
      "resources.source.1.config.format" : "resourcexml",
      "resources.source.1.config.generateFileAutomatically" : "true",
      "resources.source.1.config.includeServerNode" : "true",
      "resources.source.1.config.requireFileExists" : "false",
      "resources.source.1.type" : "file",
      "resources.source.2.config.directory" : "/home/rundeck/resources/heartbeat",
      "resources.source.2.type" : "directory",
      "resources.source.3.config.directory" : "/home/rundeck/resources/cluster",
      "resources.source.3.type" : "directory",
      "service.FileCopier.default.provider" : "jsch-scp",
      "service.NodeExecutor.default.provider" : "jsch-ssh",
    }
  }' $RUNDECK_URL/api/11/projects

#      "project.ssh-authentication" : "privateKey",
#      "project.ssh-keypath" : "/home/vagrant/.ssh/id_rsa",
fi


echo -n "Configuring Jobs..."
#on both nodes create jobs.
echo "OK"

#Create a test job which creates some file on a shared storage or do something stupid and easily detectable.($HOME/testdata)
#sleep 5
#echo "Creating test job"
#curl -sSf -H "X-Rundeck-Auth-Token: $TOKEN_R1" -F xmlBatch=@$HOME/config/test-dr/job.xml http://rundeck1:4440/$RUNDECK_ROOT/api/17/jobs/import?project=testproject



