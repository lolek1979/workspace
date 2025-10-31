#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: node.sh test-version <required>

Checks whether node --version matches the provided requirement.
EOF
}

test_version() {
    local required="${1:-}"
    if [[ -z "${required}" ]]; then
        echo "test-version requires a version string (e.g. 18.17)." >&2
        exit 2
    fi

    if ! command -v node >/dev/null 2>&1; then
        echo "Node.js is not installed or not on PATH." >&2
        exit 1
    fi

    local current
    current=$(node --version 2>/dev/null || true)

    # node --version outputs vX.Y.Z, so normalise the requirement if needed.
    if [[ "${required}" == v* ]]; then
        required="${required#v}"
    fi

    local normalised_required="v${required}"

    if [[ "${current}" == "${normalised_required}"* ]]; then
        printf 'Found required version of node %s (%s)\n' "${required}" "${current}"
    else
        printf 'Install node version %s from https://nodejs.org/download (current: %s)\n' "${required}" "${current}"
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
