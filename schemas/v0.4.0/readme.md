# Schema Change History

## Landing Zone Schemas

### February 14, 2022

Added location schema object.  This is an optional setting for archetypes.  This setting will default to `deployment().location`.

**Example**

```json
    "location": {
        "value": "canadacentral"
    }
```

### January 16, 2021
Changed `appServiceLinuxContainer` schema object to support optional inbound private endpoint.

**Example**
```json
"appServiceLinuxContainer": {
  "value": {
    "enablePrivateEndpoint": true
  }
}
```

### December 30, 2021

Changed `aks` schema object to support optional deployment of AKS using the `enabled` key as a required field.

**Example**
```json
"aks": {
  "value": {
    "enabled": true
  }
}
```

Added `appServiceLinuxContainer` schema object to support optional deployment of App Service (for model deployments) using the `enabled` key as a required field. Sku name and tier are also required fields.

**Example**
```json
"appServiceLinuxContainer": {
  "value": {
    "enabled": true,
    "skuName": "P1V2",
    "skuTier": "Premium"
  }
}
```

Added required `appService` subnet as well as the `appServiceLinuxContainer` object in machine learning schema json file.


### November 27, 2021

Change in `aks` schema object to support Options for the creation of AKS Cluster with one of the following three scenarios:

* Network Plugin: Kubenet + Network Policy: Calico (Network Policy)
* Network Plugin: Azure CNI + Network Policy: Calico (Network Policy)
* Network Plugin: Azure CNI + Network Policy: Azure (Network Policy).

| Setting | Type | Description |
| ------- | ---- | ----------- |
| version | String | Kubernetes version to use for the AKS Cluster (required) |
| networkPlugin | String | Network Plugin to use: `kubenet` (for Kubenet) **or** `azure` (for Azure CNI) (required) |
| networkPolicy | String | Network Policy to use: `calico` (for Calico); which can be used with either **kubenet** or **Azure** Network Plugins **or** `azure` (for Azure NP); which can only be used with **Azure CNI**  |

**Note**

`podCidr` value shoud be set to ( **''** ) when Azure CNI is used

**Examples**

* Network Plugin: Kubenet + Network Policy: Calico (Network Policy)

```json
"aks": {
  "value": {
    "version": "1.21.2",
    "networkPlugin": "kubenet" ,
    "networkPolicy": "calico",
    "podCidr": "11.0.0.0/16",
    "serviceCidr": "20.0.0.0/16" ,
    "dnsServiceIP": "20.0.0.10",
    "dockerBridgeCidr": "30.0.0.1/16"
  }
}
```

* Network Plugin: Azure CNI + Network Policy: Calico (Network Policy)

```json
"aks": {
  "value": {
    "version": "1.21.2",
    "networkPlugin": "azure" ,
    "networkPolicy": "calico",
    "podCidr": "",
    "serviceCidr": "20.0.0.0/16" ,
    "dnsServiceIP": "20.0.0.10",
    "dockerBridgeCidr": "30.0.0.1/16"
  }
}
```

* Network Plugin: Azure CNI + Network Policy: Azure (Network Policy).

```json
"aks": {
  "value": {
    "version": "1.21.2",
    "networkPlugin": "azure" ,
    "networkPolicy": "azure",
    "podCidr": "",
    "serviceCidr": "20.0.0.0/16" ,
    "dnsServiceIP": "20.0.0.10",
    "dockerBridgeCidr": "30.0.0.1/16"
  }
}
```
### November 26, 2021

Added Azure Recovery Vault schema to enable the creation of a Recovery Vault in the generic Archtetype subscription
| Setting | Type | Description |
| ------- | ---- | ----------- |
| enabled | Boolean | Indicate whether or not to deploy Azure Recovery Vault (required) |
| name | String | The name of the Recovery Vault |


**Examples**

Enable recovery vault | Json (used in parameter files)
```json
    "backupRecoveryVault":{
            "value": {
                "enabled":true,
                "name":"bkupvault"
            }
        }
```

### November 25, 2021

* Remove `uuid` format check on `privateDnsManagedByHubSubscriptionId` for type `schemas/latest/landingzones/types/hubNetwork.json`

### November 23, 2021

Change in `sqldb` schema object to support Azure AD authentication.

| Setting | Type | Description |
| ------- | ---- | ----------- |
| enabled | Boolean | Indicate whether or not to deploy Azure SQL Database (required) |
| aadAuthenticationOnly | Boolean | Indicate that either AAD auth only or both AAD & SQL auth (required) |
| sqlAuthenticationUsername | String | The SQL authentication user name optional, required when `aadAuthenticationOnly` is false |
| aadLoginName | String | The name of the login or group in the format of first-name last-name |
| aadLoginObjectID | String | The object id of the Azure AD object whether it's a login or a group |
| aadLoginType | String | Represent the type of the object, it can be **User**, **Group** or **Application** (in case of service principal) |

**Examples**

SQL authentication only | Json (used in parameter files)

```json
"sqldb": {
  "value": {
    "aadAuthenticationOnly":false,
    "enabled": true,
    "sqlAuthenticationUsername": "azadmin"
  }
}
```
  
SQL authentication only | bicep (used when calling bicep module from another)
  
```bicep
{
  enabled: true
  aadAuthenticationOnly: false 
  sqlAuthenticationUsername: 'azadmin'
}
```
  
Azure AD authentication only | Json (used in parameters files)
  
```json
"sqldb": {
  "value": {
    "enabled":true,
    "aadAuthenticationOnly":true,
    "aadLoginName":"John Smith",
    "aadLoginObjectID":"88888-888888-888888-888888",
    "aadLoginType":"User"
  }
}
```

Azure AD authentication only | bicep (used when calling bicep module from another)
  
```bicep
{
  enabled: true
  aadAuthenticationOnly: true 
  aadLoginName:'John Smith',
  aadLoginObjectID:'88888-888888-888888-888888',
  aadLoginType:'User'
}
```
  
Mixed authentication |  Json (used in parameters files)

```json
  "sqldb": {
    "value": {
      "enabled":true,
      "aadAuthenticationOnly":false,
      "sqlAuthenticationUsername": "azadmin",
      "aadLoginName":"John Smith",
      "aadLoginObjectID":"88888-888888-888888-888888",
      "aadLoginType":"User"
    }
  }
 ```
  
  Mixed authentication | bicep (used when calling bicep module from another)
  
```bicep
  {
    enabled: true
    aadAuthenticationOnly: false
    sqlAuthenticationUsername: 'azadmin' 
    aadLoginName:'John Smith',
    aadLoginObjectID:'88888-888888-888888-888888',
    aadLoginType:'User'
  }
```

### November 12, 2021

* Initial version based on v0.1.0 of the schema definitions.
