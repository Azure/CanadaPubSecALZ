#!/bin/sh

find $1 -type f -name '*.bicep' | xargs -tn1 az bicep build -f 