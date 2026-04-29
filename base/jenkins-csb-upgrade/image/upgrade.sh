#!/usr/bin/env bash
# https://github.com/olivergondza/bash-strict-mode
set -eEuo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

function main() {
    : "${TEAM:?variable is not set or empty}"
    : "${TENANT:?variable is not set or empty}"
    : "${NEW_VERSION:?variable is not set or empty}"

    >&2 echo "UPGRADING $TEAM/$TENANT to $NEW_VERSION"

    pwd
    ls -l
    id
}

main "$@"
