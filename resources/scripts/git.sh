#!/usr/bin/env bash
set -euo pipefail

print_usage() {
    cat <<'EOF'
Usage: restore-repositories.sh [-f repositories.json] [-b base_directory] [-d default_branch] [-l log_file]

Synchronises repositories listed in repositories.json by cloning or pulling them into the base directory.

Options:
  -f PATH   Path to repositories.json (default: resources/scripts/repositories.json relative to base directory)
  -b PATH   Base directory where repositories will be stored (default: current working directory)
  -d NAME   Default branch to checkout when not specified per repository (default: main)
  -l PATH   Optional log file to append git command output
  -h        Show this help message
EOF
}

log_file=""
repositories_file=""
base_directory=""
default_branch="main"

while getopts ":f:b:d:l:h" opt; do
    case "${opt}" in
        f) repositories_file="${OPTARG}" ;;
        b) base_directory="${OPTARG}" ;;
        d) default_branch="${OPTARG}" ;;
        l) log_file="${OPTARG}" ;;
        h)
            print_usage
            exit 0
            ;;
        \?)
            echo "Unknown option: -${OPTARG}" >&2
            print_usage
            exit 2
            ;;
        :)
            echo "Option -${OPTARG} requires an argument." >&2
            print_usage
            exit 2
            ;;
    esac
done
shift $((OPTIND - 1))

if [[ -z "${base_directory}" ]]; then
    base_directory="$(pwd)"
fi

mkdir -p "${base_directory}"
base_directory="$(cd "${base_directory}" && pwd)"

if [[ -z "${repositories_file}" ]]; then
    repositories_file="${base_directory}/resources/scripts/repositories.json"
elif [[ ! "${repositories_file}" = /* ]]; then
    repositories_file="$(cd "$(pwd)" && realpath "${repositories_file}")"
fi

if [[ ! -f "${repositories_file}" ]]; then
    echo "Unable to locate repositories list at ${repositories_file}" >&2
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

    if [[ "${relative_path}" == "." ]]; then
        target_dir="${base_directory}"
    else
        target_dir="${base_directory}/${relative_path}"
    fi

    git_dir="${target_dir}/.git"

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
        clone_args=(clone "${url}" "${target_dir}")
        if [[ -n "${branch}" ]]; then
            clone_args+=(--branch "${branch}")
        fi
        run_git "${clone_args[@]}"
    fi

    printf '\n'
done
