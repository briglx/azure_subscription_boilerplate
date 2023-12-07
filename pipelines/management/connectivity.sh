# shellcheck shell=bash
# Functions to provision connectivity infrastructure
create_core_vnet(){
  local vnet_core_name="$1"
  local rg_name="$2"
  local location="$3"

  # vnet_core_name=vnet-hub-core-$location
  vnet_core_cidr='10.0.0.0/16'
  vnet_core_subnet_bastion_name=AzureBastionSubnet
  vnet_core_subnet_bastion_cidr='10.0.255.64/27'
  vnet_core_subnet_bastion_ip_bastion_name=core_bastion_ip
  vnet_core_subnet_bastion_bastion_core_name=core_bastion
  # vnet_core_subnet_jump_box_name=snet-jumpbox
  # vnet_core_subnet_jump_box_cidr='10.0.0.0/29'
  # # vnet_core_subnet_firewall_name=snet-firewall
  # # vnet_core_subnet_firewall_cidr='10.0.0.8/29'
  # vnet_core_subnet_management_name=snet-management
  # vnet_core_subnet_management_cidr='10.0.0.64/26'

  # create vnet
  echo creating "$vnet_core_name" vnet in "$rg_name"
  # create_vnet "$vnet_core_name" "$rg_name" "$vnet_core_cidr"
  az network vnet create --resource-group "$rg_name" --name "$vnet_core_name" --address-prefixes "$vnet_core_cidr"

  # core bastion subnet
  echo "creating subnet $vnet_core_subnet_bastion_name"
  # create_subnet "$vnet_core_subnet_bastion_name" "$vnet_core_name" "$rg_name" "$vnet_core_subnet_bastion_cidr"
  az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_bastion_cidr"
  az network public-ip create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_ip_bastion_name" --sku Standard --location "$location" --zone 1 2 3
  echo "Y" | az network bastion create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_bastion_core_name" --public-ip-address "$vnet_core_subnet_bastion_ip_bastion_name"  --vnet-name "$vnet_core_name" --location "$location"
  # # jumpbox subnet
  # echo "creating subnet $vnet_core_subnet_jump_box_name"
  # az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_jump_box_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_jump_box_cidr"
  # # management subnet
  # echo "creating subnet $vnet_core_subnet_management_name"
  # az network vnet subnet create --resource-group "$rg_name" --name "$vnet_core_subnet_management_name" --vnet-name "$vnet_core_name" --address-prefixes "$vnet_core_subnet_management_cidr"
}

# # Global
# PROJ_ROOT_PATH=$(cd "$(dirname "$0")"/..; pwd)
# echo "Project root: $PROJ_ROOT_PATH"
# SCRIPT_DIRECTORY="${PROJ_ROOT_PATH}/script"

# # shellcheck source=common.sh
# source "${SCRIPT_DIRECTORY}/common.sh"

#######################################################
# Variables RG
#######################################################

provision_connectivity(){
  # Provision connectivity resources including:
  # Core Hub:
  # - Resource group, hub vnet, bastion subnet,
  # - jumpbox subnet, management subnet
  # - Network watcher

  # variables
  hub_name="core"
  location="westus3"
  jumpbox=false
  # environment="prod"
  rg_name="rg_${hub_name}_${location}"
  vnet_core_name="vnet-${hub_name}-${location}"
  vnet_core_cidr='10.0.0.0/16'
  vnet_core_subnet_bastion_name=AzureBastionSubnet
  vnet_core_subnet_bastion_cidr='10.0.255.64/27'
  vnet_core_subnet_bastion_ip_bastion_name="${hub_name}_bastion_ip"
  vnet_core_subnet_bastion_bastion_core_name="${hub_name}_bastion"
  vnet_core_subnet_jump_box_name=snet-jumpbox
  vnet_core_subnet_jump_box_cidr='10.0.0.0/29'
  vnet_core_subnet_firewall_name=snet-firewall
  vnet_core_subnet_firewall_cidr='10.0.0.8/29'
  vnet_core_subnet_management_name=snet-management
  vnet_core_subnet_management_cidr='10.0.0.64/26'

  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --parameters)
          shift
          # Assume it's key-value pairs passed directly
          while [ -n "$1" ] && [ "${1:0:1}" != "-" ]; do
              key="${1%%=*}"
              value="${1#*=}"
              local "$key=$value"
              shift
          done
          ;;
      *)
          echo "Unknown option: $1"
          exit 1
          ;;
    esac
  done

  # Resource Group
  create_resource_group "$rg_name" "$location"

  # Network watcher
  echo "creating network watcher in $rg_name"
  az network watcher configure --resource-group "$rg_name" --locations "$location" --enabled

  # Core Vnet
  create_vnet "$vnet_core_name" "$rg_name" "$vnet_core_cidr"

  # Bastion
  create_subnet "$vnet_core_subnet_bastion_name" "$vnet_core_name" "$rg_name" "$vnet_core_subnet_bastion_cidr"
  echo "creating public ip $vnet_core_subnet_bastion_ip_bastion_name"
  az network public-ip create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_ip_bastion_name" --sku Standard --location "$location" --zone 1 2 3
  echo "Y" | az network bastion create --resource-group "$rg_name" --name "$vnet_core_subnet_bastion_bastion_core_name" --public-ip-address "$vnet_core_subnet_bastion_ip_bastion_name"  --vnet-name "$vnet_core_name" --location "$location"

  # Jumpbox
  if [ "$jumpbox" = "true" ]; then
    echo "Create Jumpbox"
    create_subnet "$vnet_core_subnet_jump_box_name" "$vnet_core_name" "$rg_name" "$vnet_core_subnet_jump_box_cidr"
  fi

  # Management Subnet
  create_subnet "$vnet_core_subnet_management_name" "$vnet_core_name" "$rg_name" "$vnet_core_subnet_management_cidr"

  # Firewall Subnet
  create_subnet "$vnet_core_subnet_firewall_name" "$vnet_core_name" "$rg_name" "$vnet_core_subnet_firewall_cidr"

}

# provision_connectivity --parameters location=westus3
