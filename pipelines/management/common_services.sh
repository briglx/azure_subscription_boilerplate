#!/bin/bash
#######################################################
# Common Services RG Script
# Params
# --rg_region Resource Region. Default westus2
#######################################################
echo starting script

# Stop on errors
set -e

# Global
prefix=''
rg_region=${rg_region:-westus3}

# Parse params
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
 param="${1/--/}"
 declare $param="$2"
  fi
 shift
done

# Add Dev prefix
if [ $target_env == "dev" ]; then
  prefix="DEV_"
fi

#######################################################
# Variables RG
#######################################################
rg_name=$prefix${rg_name:-rg_common}


let "randomIdentifier=$RANDOM*$RANDOM"
kv_name="keyvault-$randomIdentifier"


# resource group
echo creating $rg_name in $rg_region
az group create --name $rg_name --location $rg_region

# create keyvault
az keyvault create --name $kv_name --resource-group $rg_name --location $rg_region