#!/bin/bash
#######################################################
# Common Services Deployment Script
# Provision common services resources including:
# - Resource group
# - Keyvault
# Params
#    --parameters  string Key-value pairs of parameters
#######################################################

main(){
  echo "Provisioning common services resources"
  # variables
  randomIdentifier=$(( RANDOM * RANDOM ))
  name="management"
  location="westus3"

  rg_name="rg_${name}_${location}"
  kv_name="kv-common-$randomIdentifier"
  log_name="log-common-$randomIdentifier"

  # Parse arguments
  echo "Parsing arguments"
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

  # Keyvault
  # create keyvault
  az keyvault create --name $kv_name --resource-group $rg_name --location $location

  # Log Analytics Workspace
  az monitor log-analytics workspace create --workspace-name "$log_name" --resource-group $rg_name

}

# main --parameters location=westus3
main "$@"
