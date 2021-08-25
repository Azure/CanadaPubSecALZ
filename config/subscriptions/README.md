# Bicep parameter files

## Disclaimer

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

## Overview

Create and maintain your Bicep parameter files in this directory.

The directory hierarchy is comprised of the following elements, from this directory downward:

1. A environment directory named for the Azure DevOps Org and Git Repo branch name, e.g. 'CanadaESLZ-main'.
2. The management group hierarchy defined for your environment, e.g. pubsec/Platform/LandingZone/Prod. The location of the config file represents which Management Group the subscription is a member of.

For example, if your Azure DevOps organization name is 'CanadaESLZ', you have two Git Repo branches named 'main' and 'dev', and you have top level management group named 'pubsec' with the standard structure, then your folder structure would look like this:

```
/config/subscriptions
    /CanadaESLZ-main           <- Your environment, e.g. CanadaESLZ-main, CanadaESLZ-dev, etc.
        /pubsec                <- Your top level management root group name
            /LandingZones
                /Prod
                    /xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx_generic-subscription.json
```

The JSON config file name is in one of the following two formats:

- [Azure Subscription GUID] _ [Template Name/Type].json
- [Azure Subscription GUID] _ [Template Name/Type] _ [Deployment Location].json


The subscription GUID is needed by the pipeline; since it's not available in the file contents it is specified in the config file name.

The template name/type is a text fragment corresponding to a folder name (or part of a folder name) under the '/landingzones' top level folder. It indicates which Bicep templates to run on the subscription.

The deployment location is the short name of an Azure deployment location, which may be used to override the `deploymentRegion` YAML variable. The allowable values for this value can be determined by looking at the `Name` column output of the command: `az account list-locations -o table`.
