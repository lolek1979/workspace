#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: git.sh <command> [options]

Commands:
  test-version <required>          Ensure git --version contains <required>.
  restore [options]                Clone or update repositories defined in repositories.json.

Options for restore:
  -f PATH   Override repositories.json location (default: <base>/resources/scripts/repositories.json)
  -b PATH   Base directory for repositories (default: current working directory)
  -d NAME   Default branch when none specified in JSON (default: main)
  -l PATH   Optional log file for git command output
  -h        Print command-specific help
EOF
}

print_restore_usage() {
    cat <<'EOF'
Usage: git.sh restore [-f file] [-b base] [-d branch] [-l log]

Synchronises repositories listed in repositories.json by cloning or updating them
inside the selected base directory.
EOF
}

test_git_version() {
    local required="$1"
    if [[ -z "${required}" ]]; then
        echo "A required version string is mandatory." >&2
        exit 2
    fi

    if ! command -v git >/dev/null 2>&1; then
        echo "git is not installed or not on PATH." >&2
        exit 1
    fi

    local current
    current=$(git --version 2>/dev/null || true)

    if [[ "${current}" == *"${required}"* ]]; then
        printf 'Found required version of git %s (%s)\n' "${required}" "${current}"
    else
        printf 'Install git version %s from https://git-scm.com/downloads (current: %s)\n' "${required}" "${current}"
        exit 3
    fi
}

restore_repositories() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_root
    repo_root="$(realpath "${script_dir}/../../..")"
    local repositories_file=""
    local base_directory=""
    local default_branch="main"
    local log_file=""

    OPTIND=1
    while getopts ":f:b:d:l:h" opt; do
        case "${opt}" in
            f) repositories_file="${OPTARG}" ;;
            b) base_directory="${OPTARG}" ;;
            d) default_branch="${OPTARG}" ;;
            l) log_file="${OPTARG}" ;;
            h)
                print_restore_usage
                exit 0
                ;;
            \?)
                echo "Unknown option for restore: -${OPTARG}" >&2
                print_restore_usage
                exit 2
                ;;
            :)
                echo "Option -${OPTARG} requires an argument." >&2
                print_restore_usage
                exit 2
                ;;
        esac
    done
    shift $((OPTIND - 1))

    if [[ $# -gt 0 ]]; then
        echo "Unexpected arguments: $*" >&2
        print_restore_usage
        exit 2
    fi

    if [[ -z "${base_directory}" ]]; then
        base_directory="${repo_root}"
    fi

    mkdir -p "${base_directory}"
    base_directory="$(cd "${base_directory}" && pwd)"

    if [[ -z "${repositories_file}" ]]; then
        repositories_file="$(realpath "${script_dir}/../repositories.json")"
    elif [[ ! "${repositories_file}" = /* ]]; then
        repositories_file="$(cd "$(pwd)" && realpath "${repositories_file}")"
    fi

    if [[ ! -f "${repositories_file}" ]]; then
        echo "Unable to locate repositories list at ${repositories_file}" >&2
        echo "Use -f to point to your repositories.json file if it lives elsewhere." >&2
        exit 1
    fi

    if [[ -n "${log_file}" ]]; then
        mkdir -p "$(dirname "${log_file}")"
        touch "${log_file}"
    fi

    run_git() {
        if [[ -n "${log_file}" ]]; then
            {
                printf '=== %s ===\n' "$(date -Iseconds)"
                printf '$ git %s\n' "$*"
                git "$@"
            } >>"${log_file}" 2>&1
        else
            git "$@"
        fi
    }

    mapfile -t repositories < <(python3 - <<'PY' "${repositories_file}" "${default_branch}"
import json
import os
import sys

repos_path = sys.argv[1]
default_branch = sys.argv[2]

with open(repos_path, "r", encoding="utf-8") as fh:
    data = json.load(fh)

for repo in data:
    name = repo.get("name", "<unknown>")
    url = repo.get("url")
    elements = repo.get("pathElements") or []
    branch = repo.get("branch") or default_branch

    relative_path = os.path.normpath(os.path.join(*elements)) if elements else "."
    print("\t".join([name, url or "", relative_path, branch or ""]))
PY
)

    for entry in "${repositories[@]}"; do
        IFS=$'\t' read -r name url relative_path branch <<<"${entry}"

        if [[ -z "${url}" ]]; then
            printf 'Skipping "%s": missing repository URL.\n' "${name}" >&2
            continue
        fi

        local target_dir
        if [[ "${relative_path}" == "." ]]; then
            target_dir="${base_directory}"
        else
            target_dir="${base_directory}/${relative_path}"
        fi

        local git_dir="${target_dir}/.git"

        if [[ -d "${git_dir}" ]]; then
            printf 'Updating %s\n' "${name}"
            run_git -C "${target_dir}" fetch --all --prune
            if [[ -n "${branch}" ]]; then
                run_git -C "${target_dir}" checkout "${branch}"
                run_git -C "${target_dir}" pull --ff-only origin "${branch}"
            else
                run_git -C "${target_dir}" pull --ff-only
            fi
        else
            printf 'Cloning %s\n' "${name}"
            mkdir -p "$(dirname "${target_dir}")"
            local clone_args=(clone "${url}" "${target_dir}")
            if [[ -n "${branch}" ]]; then
                clone_args+=(--branch "${branch}")
            fi
            run_git "${clone_args[@]}"
        fi

        printf '\n'
    done
}

main() {
    local command="${1:-}"
    if [[ -z "${command}" ]]; then
        usage
        exit 2
    fi

    case "${command}" in
        test-version)
            shift
            if [[ $# -lt 1 ]]; then
                echo "test-version requires a version string." >&2
                exit 2
            fi
            test_git_version "$1"
            ;;
        restore)
            shift
            restore_repositories "$@"
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
