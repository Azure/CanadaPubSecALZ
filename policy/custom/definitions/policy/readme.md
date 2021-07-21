# Custom Policy Definitions

## Folder Structure

Each policy is organized into it's own folder.  The folder name must not have any spaces nor special characters.  Each folder contains 3 files:

1. azurepolicy.config.json - metadata used by Azure DevOps Pipeline to configure the policy.
2. azurepolicy.parameters.json - contains parameters used in the policy.
3. azurepolicy.rules.json - the policy rule definition.


## Defining Policy

### azurepolicy.config.json

Example: 

```yml
{
    "name": "My custom policy name",
    "mode": "all | indexed"
}
```

The `mode` determines which resource types are evaluated for a policy definition. The supported modes are:

* all: evaluate resource groups, subscriptions, and all resource types
* indexed: only evaluate resource types that support tags and location

See [Azure Policy Reference](https://docs.microsoft.com/azure/governance/policy/concepts/definition-structure#mode) for more information.


### azurepolicy.parameters.json

See [Azure Parameter Reference](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#parameters) for more information.

Example: 
```yml
{
    "effect": {
        "type": "String",
        "metadata": {
            "displayName": "Effect",
            "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
            "auditIfNotExists",
            "DeployIfNotExists",
            "Disabled"
        ],
        "defaultValue": "DeployIfNotExists"
    },
    "planId": {
        "type": "String",
        "metadata": {
            "displayName": "DDoS Protection Plan Resource ID",
            "description": "Full resource ID of the DDoS Protection Plan to be associated to VNets"
        }
    }
}
```

### azurepolicy.rules.json

Describes the policy rule that will be evaluated by Azure Policy.  The rule can have any effect such as Audit, Deny, DeployIfNotExists.

Example:

```yml
{
    "if": {
        "allOf": [
            {
                "field": "type",
                "equals": "Microsoft.Network/virtualNetworks"
            }
        ]
    },
    "then": {
        "effect": "[parameters('effect')]",
        "details": {
            "type": "Microsoft.Network/virtualNetworks",
            "name": "[field('name')]",
            "existenceCondition": {
                "allOf": [
                    {
                        "field": "Microsoft.Network/virtualNetworks/enableDdosProtection",
                        "equals": "true"
                    },
                    {
                        "field": "Microsoft.Network/virtualNetworks/ddosProtectionPlan",
                        "notEquals": ""
                    }
                ]
            },
            "roleDefinitionIds": [
                "/providers/microsoft.authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7"
            ],
            "deployment": {
                "properties": {
                    "mode": "incremental",
                    "template": {
                        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
                        "contentVersion": "1.0.0.0",
                        "parameters": {
                            "vnetName": {
                                "type": "string"
                            },
                            "planId": {
                                "type": "string"
                            },
                            "vnetLocation": {
                                "type": "string"
                            }
                        },
                        "resources": [
                            {
                                "apiVersion": "2017-08-01",
                                "name": "ApplyDDoS",
                                "type": "Microsoft.Resources/deployments",
                                "resourceGroup": "[resourceGroup().name]",
                                "properties": {
                                    "mode": "Incremental",
                                    "template": {
                                        "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
                                        "contentVersion": "1.0.0.0",
                                        "resources": [
                                            {
                                                "type": "Microsoft.Network/virtualNetworks",
                                                "apiVersion": "2019-11-01",
                                                "name": "[parameters('vnetName')]",
                                                "location": "[parameters('vnetLocation')]",
                                                "properties": {
                                                    "addressSpace": "[reference(resourceId('Microsoft.Network/virtualNetworks', parameters('vnetName')), '2020-07-01', 'Full').properties.addressSpace]",
                                                    "subnets": "[reference(resourceId('Microsoft.Network/virtualNetworks', parameters('vnetName')), '2020-07-01', 'Full').properties.subnets]",
                                                    "enableDdosProtection": true,
                                                    "ddosProtectionPlan": {
                                                        "id": "[parameters('planId')]"
                                                    }
                                                }
                                            }
                                        ]
                                    }
                                }
                            }
                        ]
                    },
                    "parameters": {
                        "vnetName": {
                            "value": "[field('name')]"
                        },
                        "planId": {
                            "value": "[parameters('planId')]"
                        },
                        "vnetLocation": {
                            "value": "[field('location')]"
                        }
                    }
                }
            }
        }
    }
}
```


## Policy Reference for Assignment or Initiative Definition

By default, all custom policies are deployed to the top level management group.  This management group is configured in the environment configuration yaml (i.e. config\variables\CanadaESLZ-main.yml). 

```yml
  var-topLevelManagementGroupName: pubsec
```

To reference a definition for either a policy assignment or a policy set definition, use the folder name as the reference name.

For example, to reference the policy `Network-Deploy-DDoS-Standard`:

Format:

```
/providers/Microsoft.Management/managementGroups/TOP_LEVEL_MANAGEMENT_GROUP_ID/providers/Microsoft.Authorization/policyDefinitions/POLICY_ID
```

Replace:

* __POLICY_ID__ = Network-Deploy-DDoS-Standard
* __TOP_LEVEL_MANAGEMENT_GROUP_ID__ = value from `var-topLevelManagementGroupName`

Example:

```
/providers/Microsoft.Management/managementGroups/pubsec/providers/Microsoft.Authorization/policyDefinitions/Network-Deploy-DDoS-Standard
```

## Generate Log Analytics Diagnostic Settings Policy Definitions

The easiest approach is to use the scripts from GitHub ([JimGBritt/AzurePolicy](https://github.com/JimGBritt/AzurePolicy/tree/master/AzureMonitor/Scripts)).  The steps are:

1. Deploy an instance of the Azure Service (i.e. Azure Bastion)
2. Execute `Create-AzDiagPolicy.PS1` - Follow instructions in [GitHub](https://github.com/JimGBritt/AzurePolicy/blob/master/AzureMonitor/Scripts/README.md#overview-of-create-azdiagpolicyps1)
3. Copy the contents of the generated files into `azurepolicy.parameters.json` and `azurepolicy.rules.json`.
4. Create `azurepolicy.config.json` with policy name and mode.
5. Delete the instance created in step 1.
