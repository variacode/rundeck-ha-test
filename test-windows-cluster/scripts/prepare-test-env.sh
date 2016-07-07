#!/bin/bash

set -ex

#Create temp dir
WORKDIR=tmp
mkdir -p $WORKDIR

# Get rome rundeck tools
git clone https://github.com/rerun/rerun $WORKDIR/rerun
git clone https://github.com/rerun-modules/rundeck-apitokens $WORKDIR/rerun/modules/rundeck-apitokens
git clone https://github.com/rerun-modules/rundeck-system $WORKDIR/rerun/modules/rundeck-system
git clone https://github.com/rerun-modules/rundeck-plugin $WORKDIR/rerun/modules/rundeck-plugin


#Build tools
$WORKDIR/rerun/rerun stubbs:archive -f testdata/utils/rrtokens --modules rundeck-apitokens
$WORKDIR/rerun/rerun stubbs:archive -f testdata/utils/rrsystem --modules rundeck-system

#Creare rundeck-system plugin
$WORKDIR/rerun/rerun rundeck-plugin:node-steps \
  --name rundeck-system \
  --version 1.0.0 \
  --modules rundeck-system \
  --build-dir $WORKDIR/rerun-builds

#Check plugin creation
test -f $WORKDIR/rerun-builds/rundeck-system.zip

# Provision plugin.
mkdir -p testdata/plugins
cp -a $WORKDIR/rerun-builds/rundeck-system.zip testdata/plugins/.



