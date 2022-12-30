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
rg_name=$prefix${rg_name:-rg_connectivity}

vnet_core_name=vnet-hub-core-$rg_region