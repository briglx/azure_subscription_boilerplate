#!/bin/bash
#######################################################
# Core Infrastructure Script
# Globals
#   TENANT_ID
#   WEB_APP_CLIENT_ID
#   WEB_APP_CLIENT_SECRET
#   DATABASE_DB
#   DATABASE_ADMIN_ID
#   DATABASE_USER
# Params
# --rg_region Resource Region. Default westus3
#######################################################
echo starting script

# Stop on errors
set -e

# Globals
PROJ_ROOT_PATH=$(cd "$(dirname "$0")"/..; pwd)
echo "Project root: $PROJ_ROOT_PATH"
SCRIPT_DIRECTORY="${PROJ_ROOT_PATH}/script"
ENV_FILE="${PROJ_ROOT_PATH}/.env"

# Global
prefix=''
rg_region=${rg_region:-westus3}
iso_date_utc=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

# Parse params
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
 param="${1/--/}"
 declare "$param"="$2"
  fi
 shift
done

#######################################################
# Variables RG
#######################################################
# Global
rg_region="westus"
rg_core="rg_core_$rg_region"

# Variables RG
randomIdentifier=$(( RANDOM * RANDOM ))
rg_name="${app_name}_${rg_region}_rg"