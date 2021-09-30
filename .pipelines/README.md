# Azure Pipelines

## Disclaimer

Copyright (c) Microsoft Corporation.

Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

## Pipeline definitions

The following top-level pipelines are present in the `.pipelines/` repository folder:

| # | Pipeline | File | CI Name
| :---: | ---------- | ---------- | ----------
| 1 | Management Groups | `management-groups.yml` | management-groups-ci
| 2 | Platform Logging | `platform-logging.yml` | platform-logging-ci
| 3 | Policy | `policy.yml` | policy-ci
| 4 | Roles | `roles.yml` | roles-ci
| 5 | Networking | `platform-connectivity-hub-nva.yml` | platform-connectivity-hub-nva-ci
| 6 | Subscription | `subscription.yml` | subscription-ci

These pipelines need to be run in the order specified. For example, the `Policy` pipeline is dependent on resources deployed by the `Platform Logging` pipeline. Think of it as a layered approach; once the layer is deployed, it only requires re-running if some configuration at that layer changes.

In the default implementation, the `Management Groups`, `Platform Logging`, `Policy`, and `Roles` pipelines are run automatically (trigger) whenever a related code change is detected on the `main` branch. The `Networking` and `Subscription` pipelines do not run automatically (no trigger). This behavior can be changed by modifying the corresponding YAML pipeline definition files.

In the default implementation, the `Roles` and `Platform Logging` pipelines are run automatically after a successful run of the `Management Groups` pipeline, and the `Policy` pipeline is run automatically after a successful run of the `Platform Logging` pipeline. Again, this behavior can be changed by modifying the corresponding YAML pipeline definition files.

The top-level pipeline definitions are implemented in a modular way, using nested YAML templates defined in the `.pipelines/templates/jobs/` and `.pipelines/templates/steps/` paths.

## Pipeline configuration

The top-level pipelines use configuration values from these locations:

- environment related configuration values are stored in the `config/variables/` path.
- subscription related configuration values are stored in the `config/subscriptions/` path.

Additional information on configuration files is available here:

- [Environment configuration files](../config/variables/README.md)
- [Subscription configuration files](../config/subscriptions/README.md)

## Additional pipelines

In addition to the top-level pipelines mentioned previously, there are several other pipeline definitions in the `./pipelines` path that may be useful.

### Check Bicep files

The `checks-bicep-compile.yml` pipeline can be used to configure a `Build Validation` branch policy in your repository and validate any Bicep code changes by compiling all Bicep files with built-in linting.

### Manual approval

The `demo-approval.yml` pipeline demonstrates how to implement a manual approval gate/check in your pipeline definition.

### Linting source files

The `linters.yml` pipeline demonstrates using the GitHub SuperLinter project to run a linting process on many common source code file types.
