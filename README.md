# Azure Subscription Boilerplate

Example project to setup a new azure subscription for development. This project demonstrates several technologies:

* Infrastructure as Code
* Infrastructure Automation
* Management and Landing Zone organization

Network Overview

![Network Overview](docs/networkoverview.svg "Network Overview")

# Prerequisites

Prerequisites:
- Azure CLI
- Azure Subscription
- GitHub Account

## Install Azure CLI

```bash
# Check if installed
az --version

sudo apt-get update
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

AZ_REPO=$(lsb_release -cs) 
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |  sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
sudo apt-get install azure-cli

az --version
```

# Quick Start

Get started creating a new subscription.

* Clone this project and Create a local.env
* Configure GitHub

## Clone Project

```bash
# clone project
git clone https://github.com/briglx/azure_subscription_boilerplate.git

# Navigate to Recipes
cd azure_subscription_boilerplate

# Set Secrets in .env
AZURE_TENANT_ID=ReplaceWithYourTenantId
AZURE_SUBSCRIPTION_ID=ReplaceWithYourSubscriptionId
GITHUB_ORG=ReplaceWithYourGitHubOrgOrUserName
GITHUB_REPO=RepalceWithYourRepoName

cp example.env .env
sed -i "s/<tenant_id>/$AZURE_TENANT_ID/" .env
sed -i "s/<subscription_id>/$AZURE_SUBSCRIPTION_ID/" .env
sed -i "s/<github_org>/$GITHUB_ORG/" .env
sed -i "s/<github_repo>/$GITHUB_REPO/" .env
```

## Configure GitHub

Create An Azure Active Directory application, with a service principal that has contributor access to your subscription. The application uses OpenId Connect (OIDC) based Federated Identity Credentials.

```bash
# load .env vars (optional)
[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

app_name=github_cicd_service_app
app_secret_name=github_cicd_client_secret

az login --tenant $AZURE_TENANT_ID

# Create an Azure Active Directory application and a service principal.
app_id=$(az ad app create --display-name $app_name --query id -o tsv)
app_client_id=$(az ad app list --display-name $app_name --query [].appId -o tsv)
# Save app_id to .env APP_CLIENT_ID
echo AZURE_CLIENT_ID=$app_client_id >> .env
az ad sp create --id $app_id

# Assign contributor role to the app service principal
app_sp_id=$(az ad sp list --all --display-name $app_name --query "[].id" -o tsv)
az role assignment create --assignee $app_sp_id --role contributor --scope /subscriptions/$AZURE_SUBSCRIPTION_ID
az role assignment create --role contributor --subscription $AZURE_SUBSCRIPTION_ID --assignee-object-id  $app_sp_id --assignee-principal-type ServicePrincipal --scope /subscriptions/$AZURE_SUBSCRIPTION_ID

# Add OIDC federated credentials for the application.
post_body="{\"name\":\"$app_secret_name\","
post_body=$post_body'"issuer":"https://token.actions.githubusercontent.com",'
post_body=$post_body"\"subject\":\"repo:$GITHUB_ORG/$GITHUB_REPO:ref:refs/heads/main\","
post_body=$post_body'"description":"GitHub CICID Service","audiences":["api://AzureADTokenExchange"]}' 
az rest --method POST --uri "https://graph.microsoft.com/beta/applications/$app_id/federatedIdentityCredentials" --body "$post_body"

```

Create GitHub secrets for storing Azure configuration.

- Open your GitHub repository and go to Settings.
- Select Secrets and then New Secret.
- Create secrets for `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` from values in .env

# Migrate

## Confluence

Migrate database

```bash
# Vars
let "randomIdentifier=$RANDOM*$RANDOM"
src_host=$CONFLUENCE_SERVER_NAME
src_dbname=$CONFLUENCE_DB_NAME
src_user=$POSTGRES_USER
src_password=$POSTGRES_PASSWORD
dest_host="confluence-postgresql-server-$randomIdentifier"
dest_user=$POSTGRES_USER
dest_password=$POSTGRES_PASSWORD
rg_region="westus3"
rg_name="confluence_rg"
sku="GP_Gen5_2"
sku="Standard_B1ms" 
# Specify appropriate IP address values for your environment
# to limit / allow access to the PostgreSQL server
startIp=$MY_IP_ADDR
endIp=$MY_IP_ADDR

dns_zone_name="${dest_host}.private.postgres.database.azure.com"

rg_connectivity="rg_connectivity_westus3"
dev_vnet="vnet-dev-westus3"
confluence_subnet="snet-confluence"

# Create Destination Server
az account set -s $AZURE_SUBSCRIPTION_ID # ...or use 'az login'

echo "Using resource group $rg_name with login: $dest_user"
echo "Creating $rg_name in $rg_region..."
az group create --name $rg_name --location "$rg_region"

# DNS Zone
az network dns zone create --resource-group $rg_connectivity --name $dns_zone_name 

# Delegation
az network vnet subnet update --resource-group $rg_connectivity --name $confluence_subnet  --vnet-name $dev_vnet --delegations Microsoft.DBforPostgreSQL/flexibleServers

echo "Creating $dest_host in $rg_region..."
# az postgres server create --name $dest_host --resource-group $rg_name --location "$rg_region" --admin-user $dest_user --admin-password $dest_password --sku-name $sku
az postgres flexible-server create --name $dest_host --resource-group $rg_name --location "$rg_region" --admin-user $dest_user --admin-password $dest_password --sku-name $sku --tier Burstable


# Configure a firewall rule for the server 
echo "Configuring a firewall rule for $dest_host for the IP address range of $startIp to $endIp"
# az postgres server firewall-rule create --resource-group $rg_name --server $dest_host --name AllowIps --start-ip-address $startIp --end-ip-address $endIp
az postgres flexible-server firewall-rule create --resource-group $rg_name --name $dest_host --rule-name AllowIps --start-ip-address $startIp --end-ip-address $endIp


# az postgres server show --resource-group $rg_name --name $dest_host
az postgres flexible-server show --resource-group $rg_name --name $dest_host

# Connect to db
# PGPASSWORD=$dest_password psql "sslmode=verify-full sslrootcert=BaltimoreCyberTrustRoot.crt host=$dest_host.postgres.database.azure.com dbname=postgres user=$dest_user@$dest_host"
PGPASSWORD=$dest_password psql --host=$dest_host.postgres.database.azure.com --port=5432 --username=$dest_user --dbname=postgres


# Start Postgres client tools
docker run --name postgres_tools -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -d postgres
# Start Postgres client tools will all env variables
docker run --name postgres_tools --env-file .env -d postgres

# Get a shell to the container
docker container exec -it postgres_tools /bin/bash
# Get a shell to the container with env variables
docker container exec -it --env-file .env postgres_tools /bin/bash

# Stop the container
docker container stop postgres_tools

# Start the stopped container. 
docker container start postgres_tools

# Remove a container
docker container rm postgres_tools

# Migrate Database
# docker container exec -it --env-file .env postgres_tools /usr/src/app/migrate_database.sh 

# Set Vars
migration_file_name="migration.dump.tar"
src_host=$CONFLUENCE_SERVER_NAME
src_dbname=$CONFLUENCE_DB_NAME
src_user=$POSTGRES_USER
src_password=$POSTGRES_PASSWORD
src_host_name=$src_host.postgres.database.azure.com

# Connect to Src Host
PGPASSWORD=$src_password psql --host=$src_host_name --port=5432 --username=$src_user@$src_host --dbname=$src_dbname sslmode=verify-full sslrootcert=BaltimoreCyberTrustRoot.crt

# PGPASSWORD=$src_password pg_dump -C -h $src_host_name -U $src_user@$src_host $src_dbname | gzip > $migration_file_name
PGPASSWORD=$src_password pg_dump -C -h $src_host_name -U $src_user@$src_host -Ft  $src_dbname > $migration_file_name

# Restore to the destination
PGPASSWORD=$dest_password pg_restore -U -h $dest_host_name -U $dest_user@$dest_host -Ft -C -f $migration_file_name


# Build the image
docker build --pull --rm -f "Dockerfile.dev" -t blx_migrate_subscription:latest "."

# Run the server
docker run --rm -it --env-file .env --name blx_migrate_subscription blx_migrate_subscription:latest

# Remove a container
docker container rm blx_migrate_subscription

# Get a shell to the container
#docker container exec -it blx_migrate_subscription /bin/bash

# docker container exec -it blx_sub_migrate /usr/src/app/create_db_package.sh bacpac

```

# Style Guidelines

This project follows [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

We use [ShellCheck](https://www.shellcheck.net/) to check shell scripts.

# Testing

```bash

shellcheck script.sh
```

# References

- Use Gitub Actions to connect to Azure https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows
- OpenID Connnect Auth for GitHub https://github.com/Azure/login#configure-a-service-principal-with-a-federated-credential-to-use-oidc-based-authentication
- CAF Migration Landing Zone - https://github.com/microsoft/CloudAdoptionFramework/tree/master/ready/migration-landing-zone-governance
- Azure Security Benchmark https://learn.microsoft.com/en-us/azure/governance/blueprints/samples/azure-security-benchmark-foundation/
- Transfer Subscription https://learn.microsoft.com/en-us/azure/role-based-access-control/transfer-subscription

Bash 

- Good Bash Examples https://linuxize.com/tags/bash/
- Google Bash Standard https://google.github.io/styleguide/shellguide.html
- Shell Script Linting https://www.shellcheck.net/
