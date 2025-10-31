#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: init.sh [-e both|be|fe] [--restore-repos]

Mirrors Init.ps1 so you can prepare the workspace from Bash/WSL.

Options:
  -e, --environment    Select prerequisites to check: both (default), be, fe.
  -r, --restore-repos  Clone or update repositories defined in resources/scripts/repositories.json.
  -h, --help           Display this help message.
EOF
}

environment="both"
restore_repos=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -e|--environment)
            if [[ $# -lt 2 ]]; then
                echo "Missing value for $1." >&2
                usage
                exit 2
            fi
            environment="$2"
            shift 2
            ;;
        -r|--restore-repos)
            restore_repos=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 2
            ;;
    esac
done

case "$environment" in
    both|be|fe) ;;
    *)
        echo "Invalid environment: ${environment}. Expected both, be, or fe." >&2
        exit 2
        ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
wsl_dir="${script_dir}/resources/scripts/wsl"

if [[ ! -d "${wsl_dir}" ]]; then
    echo "WSL scripts directory not found at ${wsl_dir}. Run this from the repository root." >&2
    exit 1
fi

ensure_directory() {
    local relative="$1"
    local absolute="${script_dir}/${relative}"

    if [[ -d "${absolute}" ]]; then
        printf 'Folder %s already exists.\n' "${relative}"
    else
        mkdir -p "${absolute}"
        printf 'Created folder %s.\n' "${relative}"
    fi
}

ensure_directory "domains"
ensure_directory "frameworks"

echo "Checking Git prerequisites"
"${wsl_dir}/git.sh" test-version 2.47

echo "Checking PowerShell prerequisites"
"${wsl_dir}/pwsh.sh" test-version 7.4.6

if [[ "${environment}" == "both" || "${environment}" == "be" ]]; then
    echo "Checking backend developer prerequisites"
    "${wsl_dir}/dotnet.sh" test-version
fi

if [[ "${environment}" == "both" || "${environment}" == "fe" ]]; then
    echo "Checking frontend developer prerequisites"
    "${wsl_dir}/node.sh" test-version 22.9.0
fi

if [[ "${restore_repos}" -eq 1 ]]; then
    echo "Restoring repositories"
    "${wsl_dir}/git.sh" restore -b "${script_dir}"
fi
