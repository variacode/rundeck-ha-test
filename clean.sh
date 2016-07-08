#!/bin/bash
# Check we are in correct dir.
cd $(dirname "$0")

for composefile in $(ls -1 docker-compose-*.yml); do
  echo "=== Purging resources from $composefile..."
  docker-compose -f $composefile down --volumes --remove-orphans
done

#Purge tests data
test-windows-cluster/clean.sh





