#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: pwsh.sh test-version <required>

Validates that PowerShell (pwsh) is installed and matches the desired version.
EOF
}

test_version() {
    local required="${1:-}"
    if [[ -z "${required}" ]]; then
        echo "test-version requires a version string (e.g. 7.4.0)." >&2
        exit 2
    fi

    if ! command -v pwsh >/dev/null 2>&1; then
        echo "PowerShell (pwsh) is not installed or not on PATH." >&2
        exit 1
    fi

    local current
    current=$(pwsh --version 2>/dev/null || true)

    if [[ "${current}" == "${required}"* ]]; then
        printf 'Found PowerShell %s (%s)\n' "${required}" "${current}"
    else
        printf 'Install PowerShell %s from https://github.com/PowerShell/PowerShell/releases (current: %s)\n' "${required}" "${current}"
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
