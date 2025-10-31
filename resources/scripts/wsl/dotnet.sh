#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: dotnet.sh test-version [-v version] [-g global.json]

Ensures the required .NET SDK is installed. If -v is omitted the script reads
Sdk.Version from the provided global.json (default: ./global.json).
EOF
}

test_version() {
    local required_version=""
    local global_json="global.json"

    OPTIND=1
    while getopts ":v:g:h" opt; do
        case "${opt}" in
            v) required_version="${OPTARG}" ;;
            g) global_json="${OPTARG}" ;;
            h)
                usage
                exit 0
                ;;
            \?)
                echo "Unknown option: -${OPTARG}" >&2
                usage
                exit 2
                ;;
            :)
                echo "Option -${OPTARG} requires an argument." >&2
                usage
                exit 2
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ $# -gt 0 ]]; then
        echo "Unexpected arguments: $*" >&2
        usage
        exit 2
    fi

    if [[ -z "${required_version}" ]]; then
        if [[ ! -f "${global_json}" ]]; then
            echo "global.json not found at ${global_json}" >&2
            exit 1
        fi

        required_version=$(python3 - <<'PY' "${global_json}"
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

sdk = data.get("Sdk") or data.get("sdk") or {}
version = sdk.get("Version") or sdk.get("version")
if not version:
    raise SystemExit("Sdk.Version not found in {}".format(path))
print(version)
PY
)
    fi

    if ! command -v dotnet >/dev/null 2>&1; then
        echo ".NET SDK is not installed or not on PATH." >&2
        exit 1
    fi

    local installed
    installed=$(dotnet --list-sdks 2>/dev/null || true)

    if [[ "${installed}" == *"${required_version}"* ]]; then
        printf 'Found .NET SDK %s\n' "${required_version}"
    else
        printf 'Install .NET SDK %s from https://dotnet.microsoft.com/download (installed: %s)\n' "${required_version}" "${installed//$'\n'/, }"
        exit 3
    fi
}

main() {
    local command="${1:-}"
    if [[ -z "${command}" ]]; then
        usage
        exit 2
    fi

    shift

    case "${command}" in
        test-version)
            test_version "$@"
            ;;
        -h|--help|help)
            usage
            ;;
        *)
            echo "Unknown command: ${command}" >&2
            usage
            exit 2
            ;;
    esac
}

main "$@"
