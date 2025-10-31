#!/usr/bin/env bash
set -euo pipefail

# View appsettings from Azure Key Vault (masked) with interactive picker.
#
# Usage:
#   ./view-appsettings.sh --env dev1 [<component>] [--base64] [--grep <pattern>] [--suffix appsettings] [--list]
#   ./view-appsettings.sh --env test1 component-shadow-pdf --grep Audit
#
# Requirements:
#   - Azure CLI (az) and jq.
#   - 'az login' done, or service principal creds set.
#
# The script masks sensitive keys with ******** before displaying/saving.

# Defaults
ENVIRONMENT=""
COMPONENT=""
IS_BASE64=false
GREP_PATTERN=""
SUFFIX="appsettings"
DO_LIST=false
MASK="********"
FRAGMENTS='password|connectionstring|apikey|secret|clientsecret|token|accountkey|key'

# Map env to Key Vault name
kv_name_for_env() {
  case "$1" in
    dev1)  echo "kv-vzp-dev1-we-aks-001" ;;
    test1) echo "kv-vzp-test1-we-aks-001" ;;
    *)     echo "ERROR: Unknown environment '$1'" >&2; exit 1 ;;
  esac
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)     ENVIRONMENT="$2"; shift 2 ;;
    --base64)  IS_BASE64=true; shift ;;
    --grep)    GREP_PATTERN="$2"; shift 2 ;;
    --suffix)  SUFFIX="$2"; shift 2 ;;
    --list)    DO_LIST=true; shift ;;
    --help|-h) echo "Usage: $0 --env <dev1|test1> [component] [--base64] [--grep pattern] [--suffix appsettings] [--list]"; exit 0 ;;
    *)         if [[ -z "$COMPONENT" ]]; then COMPONENT="$1"; shift; else echo "Unknown arg: $1"; exit 1; fi ;;
  esac
done

if [[ -z "$ENVIRONMENT" ]]; then
  echo "ERROR: --env dev1|test1 is required."
  exit 1
fi

KV="$(kv_name_for_env "$ENVIRONMENT")"

# Ensure Azure CLI session
if ! az account show >/dev/null 2>&1; then
  echo "Not logged in to Azure CLI. Run 'az login' first."
  exit 1
fi

# List all components available in this KV
list_components() {
  az keyvault secret list --vault-name "$KV" --query "[].name" -o tsv \
  | awk -v sfx="-$SUFFIX" 'tolower($0) ~ (tolower(sfx) "$") {print $0}' \
  | sed -E "s/-${SUFFIX}$//"
}

# Interactive picker
pick_component() {
  local arr=()
  while IFS= read -r line; do arr+=("$line"); done < <(list_components)

  if [[ ${#arr[@]} -eq 0 ]]; then
    echo "No *-${SUFFIX} secrets found in Key Vault: $KV" >&2
    exit 1
  fi

  if command -v fzf >/dev/null 2>&1; then
    printf "%s\n" "${arr[@]}" | fzf --prompt="Select component: "
  else
    echo "Select component:" >&2
    local i=1
    for c in "${arr[@]}"; do
      printf "  %2d) %s\n" "$i" "$c" >&2
      ((i++))
    done
    read -rp "Enter number: " sel >&2
    if ! [[ "$sel" =~ ^[0-9]+$ ]] || (( sel < 1 || sel > ${#arr[@]} )); then
      echo "Invalid selection." >&2
      exit 1
    fi
    echo "${arr[$((sel-1))]}"
  fi
}

if $DO_LIST; then
  list_components
  exit 0
fi

if [[ -z "$COMPONENT" || "$COMPONENT" == "?" ]]; then
  COMPONENT="$(pick_component)"
fi

SECRET_NAME="${COMPONENT}-${SUFFIX}"
echo "Environment: $ENVIRONMENT"
echo "Key Vault  : $KV"
echo "Secret     : $SECRET_NAME"

# Fetch and mask in one go
VAL="$(az keyvault secret show --vault-name "$KV" --name "$SECRET_NAME" --query value -o tsv || true)"
if [[ -z "${VAL:-}" ]]; then
  echo "ERROR: Secret not found or empty: $SECRET_NAME" >&2
  exit 1
fi

# Decode if base64
if $IS_BASE64; then
  VAL="$(echo "$VAL" | base64 -d)"
fi

# Pretty + mask
if command -v jq >/dev/null 2>&1; then
  MASKED="$(echo "$VAL" | jq --arg mask "$MASK" --arg re "$FRAGMENTS" '
    def mask_keys:
      walk(
        if type=="object" then
          with_entries(
            if ((.key|tostring|ascii_downcase) | test($re)) then
              .value = $mask
            else . end
          )
        else . end
      );
    mask_keys
  ')"
else
  MASKED="$VAL"
fi

# Print to console
echo "$MASKED"