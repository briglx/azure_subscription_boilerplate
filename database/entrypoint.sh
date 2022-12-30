#!/bin/sh

echo "Printing Pass Arguments...\n"
printf '%d args:' "$#"
printf " '%s'" "$@"
printf '\n\n'


echo "Printing Environment Variables...\n"
printenv
printf '\n'

echo "Migration started: $(date)"

# Set Defaults
prefix=${prefix:-dump}
# src_user=${src_user:-postgres}
# src_dbname=${src_dbname:-postgres}
# src_host=${src_host:-db}
# pg_port=${pg_port:-5432}

cur_date=$(date +%Y%m%d_%H%M%S)
migration_file_name="/dump/$prefix-$cur_date.sql"

# src_host=$CONFLUENCE_SERVER_NAME
# src_dbname=$CONFLUENCE_DB_NAME
# src_user=$POSTGRES_USER
# src_password=$POSTGRES_PASSWORD
# src_host_name=$src_host.postgres.database.azure.com

# Backup the source database
PGPASSWORD=$src_password pg_dump -C -h $src_host_name -U $src_user@$src_host -Ft  $src_dbname > $migration_file_name

# Restore to the destination
PGPASSWORD=$dest_password pg_restore -U -h $dest_host_name -U $dest_user@$dest_host -Ft -C -f $migration_file_name

echo $migration_file_name
echo "migration_file_name=$migration_file_name" >> $GITHUB_OUTPUT