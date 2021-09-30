# Environment configuration files

## Disclaimer

Copyright (c) Microsoft Corporation.

Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

## Overview

Create and maintain your environment configuration (variables) files in this directory.

During execution, each top-level pipeline definition loads two variable files using the `import` directive in the `variables:` section of the pipeline definition.

The first variable file loaded is `common.yml`. This file contains variable settings that are common through all environments (org-branch combinations).

The second variable file loaded is determined using a combination of the Azure DevOps organization name and the repository branch the pipeline is operating in. For example, if your Azure DevOps organization name is `contoso`, then pipelines running on the `main` branch would load the variable file named `contoso-main` while pipelines running on the `user-feature` branch would load the variable file named `contoso-user-feature`. This allows you to separate configuration values by environment. Note that any variables re-declared in the environment variable file will override the original definition from the `common.yml` file based on their loading order.
