#!/bin/bash

set -e

# clean up test env
rm -rf testdata/* tmp
vagrant destroy --force

# re-build docker env
scripts/prepare-tests.sh

# init machines.
vagrant up

# Wait a little to start tests
echo "Waiting a little to start tests..."
sleep 10

# Start tests

# wait after finish
sleep 3

# Stop and clean all
vagrant destroy --force
rm -rf testdata/* tmp



