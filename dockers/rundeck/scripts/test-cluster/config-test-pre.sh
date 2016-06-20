#!/bin/bash
#### DR TEST CONFIGURATION.
echo "Cluster test pre config"


#Configure database
./rdpro-installer configure-datasource \
   --datasource-driver com.mysql.jdbc.Driver \
   --datasource-username rundeck \
   --datasource-password rundeck \
   --datasource-url jdbc:mysql://mysql:3306/rundeck \
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


