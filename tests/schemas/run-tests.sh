#!/bin/sh

sudo apt-get install powershell -y

pwsh -File ./test-all.ps1 -TestFolder . -SchemaFolder ../../schemas/latest/landingzones

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-generic-subscription.json' -TestFolder '../../config/subscriptions/' -FileFilter '*generic-subscription*.json'

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-machinelearning.json' -TestFolder '../../config/subscriptions/' -FileFilter '*machinelearning*.json'

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-healthcare.json' -TestFolder '../../config/subscriptions/' -FileFilter '*healthcare*.json'