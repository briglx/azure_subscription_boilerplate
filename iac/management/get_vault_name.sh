#!/bin/bash -l
###############################################################################
# Get the Key Vault name for the given environment and region.
# Parameters
#   Resource Region. Default westus3
#   Target Environment (dev, prod)
###############################################################################
set -e

readonly PROD_ENV_PREFIX="PROD"
readonly DEV_ENV_PREFIX="DEV"
readonly DEFAULT_REGION="westus3"

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

usage() {
  echo "Usage: $(basename "$0") [OPTION...] -e ENVIRONMENT -r REGION" 2>&1
  echo 'OPTIONS'
  echo '    -d Use dev environment. Sets ENVIRONMENT as "dev" and REGION as "westus3".'
  echo '    -e ENVIRONMENT'
  echo '        Pass the environment to target [dev, prod]'
  echo '    -r REGION'
  echo '        Pass the region to target [eastus, westus, westus3, etc.]'
  exit 1
}

main() {

  local -r OPT_STRING=':e:r:d'
  local ENVIRONMENT
  local REGION
  local IS_DEV_ENV
  local option
  local env_infix

  while getopts "${OPT_STRING}" option; do
    case "${option}" in
      e) ENVIRONMENT="$OPTARG" ;;
      r) REGION="$OPTARG" ;;
      d)
        IS_DEV_ENV='true'
        ENVIRONMENT="${DEV_ENV_PREFIX}"
        REGION="${DEFAULT_REGION}"
        ;;

      ?)
        err "Invalid option: -$OPTARG."
        usage
        ;;
    esac
  done
  readonly ENVIRONMENT
  readonly REGION
  readonly IS_DEV_ENV

  # Validate Parameters
  if [[ "$#" -eq 0 ]]; then
    usage
  fi
  if [[ -z "${IS_DEV_ENV}" ]]; then
    if [[ -z "${ENVIRONMENT}" ]]; then
      err 'Parameter "environment" not passed'
      usage
    fi
    if [[ -z "${REGION}" ]]; then
      err 'Parameter "region" not passed'
      usage
    fi
  fi

  # Set environment infix
  if [[ "${ENVIRONMENT}" == 'dev' ]] || [[ "${IS_DEV_ENV}" == 'true' ]]  ; then
    env_infix="${DEV_ENV_PREFIX}"
  else
    if [[ "${ENVIRONMENT}" == 'prod' ]]; then
      env_infix="${PROD_ENV_PREFIX}"
    else
      err 'Unknown "environment" passed'
      usage
    fi
  fi

  rg_name="${env_infix}_rg_common_${REGION}"
  vault_id="$(az keyvault list --resource-group "${rg_name}" --query [].id --out tsv)"

  if [[ -n "${vault_id}" ]]; then
    echo "${vault_id}"
  else
    err "Keyvault not found in resource-group ${rg_name}"
    exit 2
  fi

}

main "$@"
