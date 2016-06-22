#!/bin/bash
#### DR TEST CONFIGURATION.
echo "CLUSTER test pre config"


#Configure database
./rdpro-installer configure-datasource \
   --datasource-driver $DATABASE_DRIVER \
   --datasource-url $DATABASE_URL \
   --datasource-username $DATABASE_USER \
   --datasource-password $DATABASE_PASS \
   --rdeck-base $HOME

# Enable cluster mode
./rdpro-installer configure-clustermode \
  --enabled true \
  --rdeck-base $HOME

#Configure fixed instance UUID
./rdpro-installer configure-uuid \
  --uuid $RUNDECK_UUID \
  --rdeck-base $HOME

#Creare rundeck-system plugin
rerun/rerun rundeck-plugin:node-steps \
  --name rundeck-system \
  --version 1.0.0 \
  --modules rundeck-system \
  --build-dir $HOME/rerun-builds

# Deploy plugin
mkdir -p $HOME/libext
cp $HOME/rerun-builds/rundeck-system.zip $HOME/libext/

# Create shared resource folders
mkdir -p $HOME/resources/cluster $HOME/resources/heartbeat

