# Azure Pipelines

## Disclaimer

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

## Pipeline definitions

Pipelines present in the `pipelines/` repository folder:

| # | Pipeline | File | CI Name
| :---: | ---------- | ---------- | ----------
| 1 | Management Groups | pipelines/management-groups.yml | management-groups-ci
| 2 | Platform Logging | pipelines/platform-logging.yml | platform-logging-ci
| 3 | Policy | pipelines/policy.yml | policy-ci
| 4 | Subscription | pipelines/subscription.yml | subscription-ci

## pipelines/scripts

Script files used by Bash tasks in the pipeline definitions.

## pipelines/templates/steps

Templates for steps used by the main pipeline definitions.

## ../config/variables

Variable templates loaded by the main pipeline definitions based on environment.
