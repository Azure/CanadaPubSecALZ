## Deployment

Use Azure CLI to deploy the generic subscription landing zone.

Replace ___SUBSCRIPTION_ID___ with the Subscription ID Guid. 

```bash
az deployment sub create --subscription ___SUBSCRIPTION_ID___ --template-file main.bicep -l canadacentral
```