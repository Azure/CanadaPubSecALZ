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
| 2 | Roles | `2-roles.yml`
| 3 | Logging | `3-logging.yml`
| 4 | Policy | `policy.yml`
| 5 | Azure Firewall Policy (required for Hub Networking with Azure Firewall) | `5-azure-firewall-policy.yml`
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

All workflows take an optional `Environment Name` input. By default, the environment name is derived from a combination of the GitHub repository name and branch name, i.e. `repo-branch`. You can use the `Environment Name` input value to override the derived value, forcing the workflow to use configuration folders and files for a specific `repo-branch`.

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

## Workflow secrets

In addition to the repository-based configuration files, you will also need to create a [GitHub encrypted secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets) named `ALZ_CREDENTIALS`. This is the default secret name used by the workflows, but you can modify the workflow definition files if you would like to use different secret name(s). This secret should contain the JSON output from the `az ad sp create-for-rbac` command you used to create the service principal(s). Here is an example showing the format for this secret value as output by the `az ad sp create-for-rbac` command.

>**Note**: you will need to ensure there are no newline (carriage return / line feed) characters in the value stored in the `ALZ_CREDENTIALS` secret, as this will break the workflow definition.

```json
{
  "appId": "a1a1a1a1-b2b2-c3c3-d4d4-e5e5e5e5e5e5",
  "displayName": "alz-credentials",
  "password": "a1!b2@c3#d4$e5%f6^a1!b2@c3#d4$e5%f6^",
  "tenant": "a6a6a6a6-b7b7-c8c8-d9d9-e0e0e0e0e0e0"
}
```

>**Note**: For advanced scenarios with increased security, you should consider using a different service principal value for each workflow where each service principal has the minimum Role-Based Access Control (RBAC) permissions required by it.

If you are using the _Hub Networking with NVA_ workflow, you will also need to create [GitHub encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) named `NVA_USERNAME` and `NVA_PASSWORD`. These secret values will be used for the username and password of your Network Virtual Appliance (NVA) firewall.

>**Note**: the initial implementation of GitHub workflow definitions uses a combination of the repository name and the branch name for configuration paths & file names. This is a change from the DevOps pipelines approach where a combination of the DevOps organization name and the branch name are used. In a future release, we will convert the Azure DevOps pipelines to use the `RunWorkflows.ps1` PowerShell script, and at that time have it adopt the `repo-branch` configuration path/file naming convention used by the GitHub workflows.
