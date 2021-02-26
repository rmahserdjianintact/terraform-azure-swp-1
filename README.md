# Required variables

| Variable        | Description |
| --------------- | ----------- |
| subscription_id | Azure subscription id: https://portal.azure.com/#blade/Microsoft_Azure_Billing/SubscriptionsBlade |
| tenant_id       | Azure tenant id: https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview |
| client_id       | Azure service principal: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret |
| client_secret   | Azure client secret:  See docs for client_id above |
| prefix          | pre-pended to names in order to make them unique e.g. stage, prod, test, frodo |
<br>

# Post install

```
az login
az aks get-credentials --resource-group <prefix>-aks --name <prefix>-aks
```