#!/bin/bash
#######################################################
# Migrate Database Script
# --src_host
# --src_dbname
# --src_user
# --src_password
# --dest_host
# --dest_dbname
# --dest_user
# --dest_password
#######################################################
echo starting script
# Stop on errors
set -e

src_host="$1"
src_dbname="$2"
src_user="$3"
src_password="$4"
dest_host="$5"
dest_dbname="$6"
dest_user="$7"
dest_password="$8"

migration_file_name="migration.gz"

PGPASSWORD="$src_password" pg_dump -C -h "$src_host" -U "$src_user" "$src_dbname" | gzip > "$migration_file_name"
PGPASSWORD="$dest_password" psql -h "$dest_host" -U "$dest_user" "$dest_dbname" < "$migration_file_name"

# pg_dumpall -h $src_host -U $src_user | gzip > $migration_file_name
# psql -f db_dump $dest_db_name

# Export

/opt/mssql-tools/sqlpackage/sqlpackage /Action:"$ACTION" "/TargetFile:${FILE_NAME}.${FILE_TYPE}" /SourceServerName:"." /SourceDatabaseName:"AcoRecipes"  /SourceUser:sa "/SourcePassword:${SA_PASSWORD}"

# Import the service
server_name=localhost
database_name=AcoRecipes
database_user=sa
database_password='password used in setup'

# Publish the data-tier application (DAC). Schema, table data, user data, etc..
sqlpackage /Action:Publish /SourceFile:"AcoRecipes.dacpac" /TargetConnectionString:"Server=tcp:${server_name},1433;Initial Catalog=${database_name};Persist Security Info=False;User ID=${database_user};Password=${database_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Import schema and table data from BACPAC
sqlpackage /Action:Import /SourceFile:"AcoRecipes.bacpac" /TargetConnectionString:"Server=tcp:${server_name},1433;Initial Catalog=${database_name};Persist Security Info=False;User ID=${database_user};Password=${database_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
