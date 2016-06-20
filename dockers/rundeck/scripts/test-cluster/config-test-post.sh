#!/bin/bash
#### Cluster TEST CONFIGURATION (After rundeck start)
echo "CLUSTER test post config"


# Request apitoken for servers
echo "Requesting API token..."
APITOKEN=$($HOME/rrtokens rundeck-apitokens:create --token-user admin --url $RUNDECK_URL --username admin --password admin)
#TOKEN_R2=$($HOME/rrtokens rundeck-apitokens:create --token-user admin --url http://rundeck2:4440/$RUNDECK_ROOT --username admin --password admin)


if [[ X$RUNDECK_ROLE == 'Xleader' ]] ; then
  # Here we do the stuff needed to be executed once for the cluster. so we execute them un the leader node.

  echo "Setting node configuration..."
  cp $HOME/config/test-cluster/nodes/*.xml $HOME/resources/cluster

  # Create projects on the leader node.
  echo "Creating projects"
  curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
    "name": "PRO_HA",
    "description": "",
    "config": {
      "project.description" : "",
      "project.name" : "PRO_HA",
      "project.nodeCache.delay" : "15",
      "project.nodeCache.enabled" : "false",
      "resources.source.1.config.file" : "/home/rundeck/projects/PRO_HA/etc/resources.xml",
      "resources.source.1.config.format" : "resourcexml",
      "resources.source.1.config.generateFileAutomatically" : "true",
      "resources.source.1.config.includeServerNode" : "true",
      "resources.source.1.config.requireFileExists" : "false",
      "resources.source.1.type" : "file",
      "resources.source.2.config.directory" : "/home/rundeck/resources/heartbeat",
      "resources.source.2.type" : "directory",
      "resources.source.3.config.directory" : "/home/rundeck/resources/cluster",
      "resources.source.3.type" : "directory",
      "service.FileCopier.default.provider" : "stub",
      "service.NodeExecutor.default.provider" : "stub",
    }
  }' $RUNDECK_URL/api/11/projects
  echo -e "\nCreated PRO_HA"

  curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
    "name": "testproject",
    "description": "",
    "config": {
      "resources.source.1.config.file": "/home/rundeck/projects/testproject/etc/resources.xml",
      "resources.source.1.config.format": "resourcexml",
      "project.nodeCache.delay": "15",
      "service.FileCopier.default.provider": "stub",
      "service.NodeExecutor.default.provider": "stub",
      "resources.source.1.config.includeServerNode": "true",
      "project.nodeCache.enabled": "true",
      "resources.source.1.config.requireFileExists": "false",
      "project.name": "testproject",
      "resources.source.1.config.generateFileAutomatically": "true",
      "resources.source.1.type": "file"
    }
  }' $RUNDECK_URL/api/11/projects
  echo -e "\nCreated testproject"

else

  # Wait for project
  attempts=30
  sleep=3
  echo -n "Waiting for project."
  declare -i count=0
  while (( count <= $attempts ))
  do
      if test 2 -gt $(curl -sS -H "X-Rundeck-Auth-Token: $APITOKEN" \
                        -H "Accept: application/xml" \
                        $RUNDECK_URL/api/1/projects | grep -E "(PRO_HA|testproject)" | wc -l)
        then echo "."; # output a progress character.
        else break; # found.
      fi

      (( count += 1 ))  ; # increment attempts counter.
      (( count == $attempts )) && {
          echo >&2 "FAIL: Reached max attempts waiting for project."
          exit 1
      }
      sleep $sleep; # wait before trying again.
  done
  echo "Project created. Continuing."
fi

###### Execute tasks needed on both nodes.
echo "Configuring Jobs..."

#### Create haertbeat job.
hb_spec=$HOME/config/test-cluster/jobs/heartbeat-$RUNDECK_NODE.xml

# Config job file.
sed -i \
    -e "s|%%APIKEY%%|$APITOKEN|" \
    -e "s|%%RUNDECK_URL%%|$RUNDECK_URL|" \
    $hb_spec

# create job via api
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN" \
    -F xmlBatch=@$hb_spec \
    $RUNDECK_URL/api/17/jobs/import?project=PRO_HA


### Create takeover job.
tkov_spec=$HOME/config/test-cluster/jobs/takeover-$RUNDECK_NODE.xml

# Config job file.
sed -i \
    -e "s|%%APIKEY%%|$APITOKEN|" \
    -e "s|%%RUNDECK_URL%%|$RUNDECK_URL|" \
    $tkov_spec

# create job via api
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN" \
    -F xmlBatch=@$tkov_spec \
    $RUNDECK_URL/api/17/jobs/import?project=PRO_HA


### Create worker job
worker_spec=$HOME/config/test-cluster/jobs/job.xml

# Config job file.
sed -i -e "s|%%RUNDECK_NODE%%|$RUNDECK_NODE|" \
    $worker_spec

# create job via api
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN" \
    -F xmlBatch=@$worker_spec \
    $RUNDECK_URL/api/17/jobs/import?project=testproject


