#!/bin/bash
# Check we are in correct dir.
cd $(dirname "$0")


# Stop and clean all
vagrant destroy --force
rm -rf testdata tmp



