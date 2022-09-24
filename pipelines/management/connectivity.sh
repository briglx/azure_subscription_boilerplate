#!/bin/bash
#######################################################
# Connectivity RG Sctip
# Params
# --rg_region Resource Region. Default westus2
#######################################################
echo starting script

# Stop on errors
set -e

# Global
rg_region=${rg_region:-westus2}

# Parse params
while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
 param="${1/--/}"
 declare $param="$2"
  fi
 shift
done

rg_name=${rg_name:-rg_connectivity}_$rg_region

#######################################################
# Connectivity RG
#######################################################

# create resource group
echo creating $rg_name in $rg_region
az group create -n $rg_name -l $rg_region

# Domain VNet
vnet_domain=vnet-domain-$rg_region
vnet_domain_prefix='10.0.0.0/16'
subnet_aad_ds=snet-add-ds # domain - Azure AD Domain Services subnet
subnet_aad_ds_prefix='10.0.255.0/27'
subnet_bastion=AzureBastionSubnet
subnet_bastion_prefix='10.0.255.64/27'

# create domain vnet
echo creating domain vnet
az network vnet create -g $rg_name -n $vnet_domain --address-prefixes $vnet_domain_prefix
az network vnet subnet create -g $rg_name -n $subnet_aad_ds --vnet-name $vnet_domain --address-prefixes $subnet_aad_ds_prefix
az network vnet subnet create -g $rg_name -n $subnet_bastion --vnet-name $vnet_domain --address-prefixes $subnet_bastion_prefix

# Development VNet 
vnet_dev=vnet-dev-$rg_region
vnet_dev_prefix='10.1.0.0/16'
subnet_dev=snet-dev
subnet_dev_prefix='10.1.1.0/24'
subnet_bastion=AzureBastionSubnet
subnet_bastion_prefix='10.1.255.64/27'

# create dev vnet
echo creating dev vnet
az network vnet create -g $rg_name -n $vnet_dev --address-prefixes $vnet_dev_prefix
az network vnet subnet create -g $rg_name -n $subnet_dev --vnet-name $vnet_dev --address-prefixes $subnet_dev_prefix
az network vnet subnet create -g $rg_name -n $subnet_bastion --vnet-name $vnet_dev --address-prefixes $subnet_bastion_prefix

# Create NSG for subnets
echo creating nsg for subnets
nsg_dev=dev-nsg
az network nsg create --name $nsg_dev --resource-group $rg_name
az network vnet subnet update -g $rg_name -n $subnet_dev --vnet-name $vnet_dev --network-security-group $nsg_dev