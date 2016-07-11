#!/bin/bash

set -ex

#Read config
. metadata

#Create temp dir
WORKDIR=tmp
FILESDIR=files
mkdir -p $WORKDIR

### Get software installers
# 7z
if [ ! -f $FILESDIR/$ZIP7_INSTALLER ]
then
  echo "Downloading 7ZIP"
  wget -P $FILESDIR $SOFTWARE_URL/$ZIP7_INSTALLER
fi

# JRE
if [ ! -f $FILESDIR/$JRE_INSTALLER ]
then
  echo "Downloading JRE Installer"
  wget -P $FILESDIR $SOFTWARE_URL/$JRE_INSTALLER
fi

# Tomcat
if [ ! -f $FILESDIR/$TOMCAT_INSTALLER ]
then
  echo "Downloading Tomcat Installer"
  wget -P $FILESDIR $SOFTWARE_URL/$TOMCAT_INSTALLER
fi

# RUNDECK
echo "Downloading Rundeck WAR"
wget -O $FILESDIR/rundeckpro.war $ARTIFACTS_URL/$RUNDECK_WAR

exit 0


# Get rome rundeck tools
git clone https://github.com/rerun/rerun $WORKDIR/rerun
git clone https://github.com/rerun-modules/rundeck-apitokens $WORKDIR/rerun/modules/rundeck-apitokens
#git clone https://github.com/rerun-modules/rundeck-system $WORKDIR/rerun/modules/rundeck-system
#git clone https://github.com/rerun-modules/rundeck-plugin $WORKDIR/rerun/modules/rundeck-plugin

#Build tools
$WORKDIR/rerun/rerun stubbs:archive -f testdata/utils/rrtokens --modules rundeck-apitokens
#$WORKDIR/rerun/rerun stubbs:archive -f testdata/utils/rrsystem --modules rundeck-system

#Creare rundeck-system plugin
#$WORKDIR/rerun/rerun rundeck-plugin:node-steps \
#  --name rundeck-system \
#  --version 1.0.0 \
#  --modules rundeck-system \
#  --build-dir $WORKDIR/rerun-builds

#Check plugin creation
#test -f $WORKDIR/rerun-builds/rundeck-system.zip

# Provision rundeck system plugin.
#mkdir -p testdata/plugins
#cp -a files/rundeck-system-windows.zip testdata/plugins/.



