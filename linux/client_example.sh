#!/usr/bin/env bash
set -euo pipefail

SOCK="${1:-/run/nextgenz/daemon.sock}"
CMD="${2:-PING}"

if ! command -v socat >/dev/null 2>&1; then
  echo "socat is required: sudo apt install socat"
  exit 1
fi

printf "%s\n" "${CMD}" | socat - UNIX-CONNECT:"${SOCK}"

