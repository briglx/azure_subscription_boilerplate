
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
