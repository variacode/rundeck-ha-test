#!/bin/bash

set -e

#Create temp dir
WORKDIR=tmp
mkdir -p $WORKDIR

# Get rome rundeck tools
git clone https://github.com/rerun/rerun $WORKDIR/rerun
git clone https://github.com/rerun-modules/rundeck-apitokens $WORKDIR/rerun/modules/rundeck-apitokens
git clone https://github.com/rerun-modules/rundeck-system $WORKDIR/rerun/modules/rundeck-system
git clone https://github.com/rerun-modules/rundeck-plugin $WORKDIR/rerun/modules/rundeck-plugin


#Build tools
$WORKDIR/rerun/rerun stubbs:archive -f $WORKDIR/rrtokens --modules rundeck-apitokens
$WORKDIR/rerun/rerun stubbs:archive -f $WORKDIR/rrsystem --modules rundeck-system

#Creare rundeck-system plugin
$WORKDIR/rerun/rerun rundeck-plugin:node-steps \
  --name rundeck-system \
  --version 1.0.0 \
  --modules rundeck-system \
  --build-dir $WORKDIR/rerun-builds

#Check plugin creation
test -f $WORKDIR/rerun-builds/rundeck-system.zip


#Create shared resource folders.
mkdir -p testdata/resources/cluster testdata/resources/heartbeat

#Create logs dir
mkdir -p testdata/rundeckprologs
