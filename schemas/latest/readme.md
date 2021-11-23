# Schema Change History

## Landing Zone Schemas

* November 12, 2021

  * Initial version based on v0.1.0 of the schema definitions.
  
  * change in sqldb schema to support Azure AD authentication 
  
    ​	**enabled**: Boolean | Indicate whether or not to deploy Azure SQL Database (required)
  
    ​	**aadAuthenticationOnly**: Boolean |Indicate that either AAD auth only or both AAD & SQL auth (required)
  
    ​    **sqlAuthenticationUsername**: String | the SQL authentication user name optional, required when **aadAuthenticationOnly** is false
  
    ​	**aadLoginName**: String | the name of the login or group in the format of first-name last-name
  
    ​    **aadLoginObjectID**: String | the object id of the Azure AD object whether it's a login or a group
  
    ​    **aadLoginType**: String | represent the type of the object, it can be **User**, **Group** or **Application** (in case of service principal)
  
  
  
  ​    	**Samples:**
  
  ​			SQL authentication only | Json (used in parameter files)
  
  ```json
  "sqldb": {
   "value": {
    "aadAuthenticationOnly":false,
    "enabled": true,
    "sqlAuthenticationUsername": "azadmin"
  	}
  }
  ```
  
  

​					SQL authentication only | bicep (used when calling bicep module from another)

```json
	{
 enabled: true
 aadAuthenticationOnly: false 
 sqlAuthenticationUsername: 'azadmin'
}
```



​					Azure AD authentication only | Json (used in parameters files)

```json
"sqldb":{
 "value":{
  "enabled":true,
  "aadAuthenticationOnly":true,
  "aadLoginName":"John Smith",
  "aadLoginObjectID":"88888-888888-888888-888888",
  "aadLoginType":"User"
 }
}
```

​			

​					Azure AD authentication only | bicep (used when calling bicep module from another)

```json
{
 enabled: true
 aadAuthenticationOnly: true 
 aadLoginName:'John Smith',
 aadLoginObjectID:'88888-888888-888888-888888',
 aadLoginType:'User'
}
```



​				Mixed authentication |  Json (used in parameters files)

```json
"sqldb":{
 "value":{
  "enabled":true,
  "aadAuthenticationOnly":false,
  "sqlAuthenticationUsername": "azadmin",
  "aadLoginName":"John Smith",
  "aadLoginObjectID":"88888-888888-888888-888888",
  "aadLoginType":"User"
 }
}
```



​				Mixed authentication | bicep (used when calling bicep module from another)

```json
{
 enabled: true
 aadAuthenticationOnly: false
 sqlAuthenticationUsername: 'azadmin' 
 aadLoginName:'John Smith',
 aadLoginObjectID:'88888-888888-888888-888888',
 aadLoginType:'User'
}
```

