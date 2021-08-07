#!/bin/sh

find $1 -type f -name '*.bicep' | xargs -tn1 -P 10 az bicep build -f 