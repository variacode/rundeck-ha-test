#!/bin/bash
#### Cluster TEST CONFIGURATION (For running inside the test node)
echo "CLUSTER test config"


WORKDIR=/testdata
CONFDIR=$HOME/config

RUNDECK1_IP=192.168.50.11
RUNDECK2_IP=192.168.50.12

RUNDECK1_URL="http://rundeck1:8080/rundeckpro"
RUNDECK2_URL="http://rundeck2:8080/rundeckpro"

set -ex

#install software
sudo apt-get -y install xmlstarlet

# config /etc/hosts
sudo bash -c "echo $RUNDECK1_IP rundeck1 >> /etc/hosts"
sudo bash -c "echo $RUNDECK2_IP rundeck2 >> /etc/hosts"


# Copy config files
mkdir -p $CONFDIR
cp -a /configfiles/* $CONFDIR/.

#Wait for rundecks to be available
# Wait for server to start
MAX_ATTEMPTS=30
SLEEP=10
echo "Waiting for nodes to start. This will take about 5 minutes... "
declare -i count=0
while (( count <= MAX_ATTEMPTS ))
do
    if ! ( curl -sSfk -m5 $RUNDECK1_URL/login && curl -sSfk -m5 $RUNDECK2_URL/login )
    then  echo "Still waiting. hang on..."; # output a progress character.
    else  break; # found successful startup message.
    fi
    (( count += 1 ))  ; # increment attempts counter.
    (( count == MAX_ATTEMPTS )) && {
        echo >&2 "FAIL: Reached max attempts to reach nodes. Exiting."
        exit 1
    }
    sleep $SLEEP; # wait before trying again.
done
echo "Nodes started successfully."

sleep 3

# Request apitoken for servers
echo "Requesting API token..."
APITOKEN_R1=$($WORKDIR/utils/rrtokens rundeck-apitokens:create --token-user admin --url $RUNDECK1_URL --username admin --password admin)
APITOKEN_R2=$($WORKDIR/utils/rrtokens rundeck-apitokens:create --token-user admin --url $RUNDECK2_URL --username admin --password admin)

echo "Setting node configuration..."
mkdir -p $WORKDIR/resources/cluster

cp $CONFDIR/test-cluster/nodes/*.xml $WORKDIR/resources/cluster


# Create projects on the leader node.
echo "Creating projects"
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN_R1" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
  "name": "PRO_HA",
  "description": "",
  "config": {
    "project.description" : "",
    "project.name" : "PRO_HA",
    "project.nodeCache.delay" : "15",
    "project.nodeCache.enabled" : "false",
    "resources.source.1.config.file" : "c:\\rundeckpro\\projects\\PRO_HA\\etc\\resources.xml",
    "resources.source.1.config.format" : "resourcexml",
    "resources.source.1.config.generateFileAutomatically" : "true",
    "resources.source.1.config.includeServerNode" : "true",
    "resources.source.1.config.requireFileExists" : "false",
    "resources.source.1.type" : "file",
    "resources.source.2.config.directory" : "c:\\resources\\heartbeat",
    "resources.source.2.type" : "directory",
    "resources.source.3.config.directory" : "c:\\resources\\cluster",
    "resources.source.3.type" : "directory",
    "service.FileCopier.default.provider" : "stub",
    "service.NodeExecutor.default.provider" : "stub",
  }
}' $RUNDECK1_URL/api/11/projects
echo -e "\nCreated PRO_HA"

curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN_R1" -H "Accept: application/json" -H "Content-Type: application/json" -d '{
  "name": "testproject",
  "description": "",
  "config": {
    "resources.source.1.config.file": "c:\\rundeckpro\\projects\\testproject\\etc\\resources.xml",
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
}' $RUNDECK1_URL/api/11/projects
echo -e "\nCreated testproject"

###### Execute tasks needed on both nodes.
echo "Configuring Jobs..."

#### Create haertbeat job.
hb_spec_1=$CONFDIR/test-cluster/jobs/heartbeat-rundeck1.xml
hb_spec_2=$CONFDIR/test-cluster/jobs/heartbeat-rundeck2.xml

# Config job file.
sed -i -e "s|%%APIKEY%%|$APITOKEN_R1|" -e "s|%%RUNDECK_URL%%|$RUNDECK1_URL|" $hb_spec_1
sed -i -e "s|%%APIKEY%%|$APITOKEN_R2|" -e "s|%%RUNDECK_URL%%|$RUNDECK2_URL|" $hb_spec_2

# create job via api
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN_R1" -F xmlBatch=@$hb_spec_1 \
    $RUNDECK1_URL/api/17/jobs/import?project=PRO_HA

curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN_R2" -F xmlBatch=@$hb_spec_2 \
    $RUNDECK2_URL/api/17/jobs/import?project=PRO_HA


### Create takeover job.
tkov_spec1=$CONFDIR/test-cluster/jobs/takeover-rundeck1.xml
tkov_spec2=$CONFDIR/test-cluster/jobs/takeover-rundeck2.xml

# Config job file.
sed -i -e "s|%%APIKEY%%|$APITOKEN_R1|" -e "s|%%RUNDECK_URL%%|$RUNDECK1_URL|" $tkov_spec1
sed -i -e "s|%%APIKEY%%|$APITOKEN_R2|" -e "s|%%RUNDECK_URL%%|$RUNDECK2_URL|" $tkov_spec2

# create job via api
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN_R1" -F xmlBatch=@$tkov_spec1 \
    $RUNDECK1_URL/api/17/jobs/import?project=PRO_HA
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN_R2" -F xmlBatch=@$tkov_spec2 \
    $RUNDECK2_URL/api/17/jobs/import?project=PRO_HA

### Create worker job
worker_spec1=$CONFDIR/test-cluster/jobs/job-rundeck1.xml
worker_spec2=$CONFDIR/test-cluster/jobs/job-rundeck2.xml

# create job via api
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN_R1" -F xmlBatch=@$worker_spec1 \
    $RUNDECK1_URL/api/17/jobs/import?project=testproject
curl -sSf -H "X-Rundeck-Auth-Token: $APITOKEN_R2" -F xmlBatch=@$worker_spec2 \
    $RUNDECK2_URL/api/17/jobs/import?project=testproject


