#!/bin/sh

sudo apt-get install powershell -y

pwsh -File ./test-all.ps1 -TestFolder . -SchemaFolder ../../schemas/latest/landingzones

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-platform-logging.json' -TestFolder '../../config/logging/' -FileFilter '*.json'

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-platform-connectivity-hub-azfw-policy.json' -TestFolder '../../config/networking/*/hub-azfw-policy/' -FileFilter '*.json'

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-platform-connectivity-hub-azfw.json' -TestFolder '../../config/networking/*/hub-azfw/' -FileFilter '*.json'

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-platform-connectivity-hub-nva.json' -TestFolder '../../config/networking/*/hub-nva/' -FileFilter '*.json'

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-generic-subscription.json' -TestFolder '../../config/subscriptions/' -FileFilter '*generic-subscription*.json'

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-machinelearning.json' -TestFolder '../../config/subscriptions/' -FileFilter '*machinelearning*.json'

pwsh -File ./validate-deployment-config.ps1  -SchemaFile '../../schemas/latest/landingzones/lz-healthcare.json' -TestFolder '../../config/subscriptions/' -FileFilter '*healthcare*.json'