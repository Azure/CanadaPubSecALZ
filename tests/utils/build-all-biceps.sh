#!/bin/sh

mkdir -p /tmp/bicepbuild

find $1 -type f -name '*.bicep' | xargs -tn1 az bicep build --outdir /tmp/bicepbuild -f 

rm -rf /tmp/bicepbuild