#!/bin/bash
echo starting script
#######################################################
# Connectivity RG
#######################################################
# create resource group
echo creating $rg_name in $rg_name
az group create -n $rg_name -l $rg_name

# create core vnet
echo creating core vnet
az network vnet create -g $rg_name -n $vnet_core --address-prefixes $vnet_core_prefix
az network vnet subnet create -g $rg_name -n $subnet_aad_ds --vnet-name $vnet_core  --address-prefixes $subnet_aad_ds_prefix
az network vnet subnet create -g $rg_name -n $subnet_bastion --vnet-name $vnet_core  --address-prefixes $subnet_bastion_prefix

# create dev vnet
echo creating dev vnet
az network vnet create -g $rg_name -n $vnet_dev --address-prefixes $vnet_dev_prefix
az network vnet subnet create -g $rg_name -n $subnet_dev --vnet-name $vnet_dev  --address-prefixes $subnet_dev_prefix

# Create NSG for subnets
echo creating nsg for subnets
nsg_dev=dev-nsg
az network nsg create --name $nsg_dev --resource-group $rg_name
az network vnet subnet update -g $rg_name -n $subnet_dev --vnet-name  $vnet_dev --network-security-group $nsg_dev