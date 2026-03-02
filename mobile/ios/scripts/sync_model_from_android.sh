#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_MODEL="${ROOT}/../android/app/src/main/assets/model"
IOS_MODEL="${ROOT}/Shared/Model"

cp "${ANDROID_MODEL}/prefix.tsv" "${IOS_MODEL}/prefix.tsv"
cp "${ANDROID_MODEL}/next.tsv" "${IOS_MODEL}/next.tsv"
echo "Synced iOS model from Android assets."

