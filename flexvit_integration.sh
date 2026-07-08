#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}" && pwd)"

find_secda_root() {
  local dir="${script_dir}"

  while [[ "${dir}" != "/" ]]; do
    if [[ "$(basename "${dir}")" == "SECDA-TFLite" ]]; then
      printf '%s\n' "${dir}"
      return 0
    fi

    dir="$(dirname "${dir}")"
  done

  return 1
}

secda_root="$(find_secda_root || true)"

if [[ -z "${secda_root}" ]]; then
  echo "error: place FlexViT under a SECDA-TFLite checkout before running this script" >&2
  echo "example: <SECDA-TFLite>/FlexViT/flexvit_integration.sh" >&2
  exit 1
fi

copy_overlay() {
  local source_dir="$1"
  local target_dir="$2"

  mkdir -p "${target_dir}"

  if command -v rsync >/dev/null 2>&1; then
    rsync -a "${source_dir}/" "${target_dir}/"
  else
    cp -a "${source_dir}/." "${target_dir}/"
  fi
}

echo "[1/2] Copying FlexViT source overlay into SECDA-TFLite..."
copy_overlay "${repo_root}/src" "${secda_root}"

echo "[2/2] Merging VS Code launch/tasks into SECDA-TFLite..."
bash "${repo_root}/patch_vscode.sh"

echo "FlexViT integration completed successfully."