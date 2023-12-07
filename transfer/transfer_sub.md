# Transfer subscription

Doesn't work for Internal Subscriptions

```bash

# Set subscription
az account set --subscription "Marketing"

# Save all Role assignments
az role assignment list --all --include-inherited --output tsv > roleassignments.tsv

# Save Custom roles
az role definition list --custom-role-only true --output json --query '[].{roleName:roleName, roleType:roleType}'
az role definition list --name custom_role_name customrolename.json
```

# References
https://learn.microsoft.com/en-us/azure/role-based-access-control/transfer-subscription
