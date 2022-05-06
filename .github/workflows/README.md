# GitHub Workflows

## Disclaimer

Copyright (c) Microsoft Corporation.

Licensed under the MIT license.

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

## Workflow definitions

The following workflows are present in the `.github/workflows` repository folder:

| # | Workflow | File
| :---: | ---------- | ----------
| 0 | Everything | `0-everything.yml`
| 1 | Management Groups | `1-management-groups.yml`
| 2 | Custom Roles | `2-roles.yml`
| 3 | Logging | `3-logging.yml`
| 4 | Policy | `policy.yml`
| 5 | Hub Networking with Azure Firewall | `5-hub-network-with-azure-firewall.yml`
| 5 | Hub Networking with NVA | `5-hub-network-with-nva.yml`
| 6 | Subscriptions | `6-subscriptions.yml`

With the exception of the `Everything` workflow, all other workflows need to be run in the order specified. For example, the `Policy` workflow is dependent on resources deployed by the `Logging` workflow. Think of it as a layered approach; once the layer is deployed, it only requires re-running if some configuration at that layer changes.

The `Everything` workflow runs all the other workflows, in order, as a series of steps within a single job. It is useful for your initial deployment, saving you the extra work of running each of the six workflows individually.

This workflow takes two input parameters, one specifying the hub network type and the other specifying an optional list of zero or more subscription ids (or partial ids).

The hub network type input value can be one of:

- HubNetworkWithAzureFirewall
- HubNetworkWithNVA

The subscription ids input value can be one of:

- Empty, in which case no subscriptions are deployed.
- A single value consisting of all or part of the subscription id, e.g. `640251f9`.
- A series of quoted comma-delimited values consisting of values representing all or part of multiple subscription ids, e.g. `"640251f9","49f510ff","aef2d8e7"`.

There are two `Hub Networking` workflows, but you only need to run one of them. The networking workflow you run is based on whether you choose to implement the Azure Firewall or a Network Virtual Appliance (NVA).

In the default implementation, all workflows are run manually. This behavior can be changed by modifying the corresponding YAML workflow definition files. For example, to trigger workflow on a push or pull request to the repository.

These workflow definitions are implemented using modularized PowerShell scripts in the `scripts/deployments`  path. The main entry point for these scripts is `scripts/deployments/RunWorkflows.ps1`.

## Workflow configuration

These workflows use configuration values from the following locations:

- environment related configuration values are stored in the `config/variables` path.
- logging related configuration values are stored in the `config/logging` path.
- network related configuration values are stored in the `config/networking` path.
- subscription related configuration values are stored in the `config/subscriptions` path.

Additional information on configuration files is available here:

- [Environment configuration files](../config/variables/README.md)
- [Subscription configuration files](../config/subscriptions/README.md)

In addition to the repository-based configuration files, you will also need to create a [GitHub encrypted secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets) named `AZURE_CREDENTIALS`. This secret should contain the JSON output from the `az ad sp create-for-rbac` command you used to create the service principal - ensure you remove any newline characters present in the JSON representation when you create the secret as those characters will break the workflow.

>NOTE: The initial implementation of GitHub workflow definitions uses a combination of the repository name and the branch name for configuration paths & file names. This is a change from the DevOps pipelines approach where a combination of the DevOps organization name and the branch name are used. In a future release, we will convert the Azure DevOps pipelines to use the `RunWorkflows.ps1` PowerShell script, and at that time have it adopt the `repo-branch` configuration path/file naming convention used by the GitHub workflows.
