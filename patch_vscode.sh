#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  exit 1
fi

src_vscode="${script_dir}/src/tensorflow"
dst_vscode="${secda_root}/tensorflow/.vscode"

if [[ ! -d "${src_vscode}" ]]; then
  echo "error: missing source vscode folder: ${src_vscode}" >&2
  exit 1
fi

mkdir -p "${dst_vscode}"

python3 - "${src_vscode}" "${dst_vscode}" <<'PY'
import json
import os
import re
import shutil
import sys

src_vscode, dst_vscode = sys.argv[1:3]


def load_json_like(path, fragment_key):
    text = open(path, "r", encoding="utf-8").read()
    stripped = []
    in_string = False
    escaped = False
    i = 0
    while i < len(text):
        char = text[i]
        if in_string:
          
            stripped.append(char)
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            i += 1
            continue
        if char == '"':
            in_string = True
            stripped.append(char)
            i += 1
            continue
        if char == "/" and i + 1 < len(text) and text[i + 1] == "/":
            while i < len(text) and text[i] not in "\n\r":
                i += 1
            continue
        if char == "/" and i + 1 < len(text) and text[i + 1] == "*":
            i += 2
            while i + 1 < len(text) and not (text[i] == "*" and text[i + 1] == "/"):
                i += 1
            i += 2
            continue
        stripped.append(char)
        i += 1

    text = re.sub(r",\s*([}\]])", r"\1", "".join(stripped))
    text = text.strip()
    if not text:
        return {"version": "0.2.0", fragment_key: []}

    try:
        return json.loads(text)
    except Exception:
        for key in (fragment_key, "configurations" if fragment_key == "tasks" else "tasks"):
            version = "2.0.0" if key == "tasks" else "0.2.0"
            wrapped = '{"version":"' + version + '","' + key + '":[' + text + ']}'
            try:
                return json.loads(wrapped)
            except Exception:
                continue
        raise


def key_of(item):
    return item.get("label") or item.get("taskName") or item.get("id")


def merge_launch(src_path, dst_path):
    if not os.path.exists(src_path):
        return
    src_data = load_json_like(src_path, "configurations")
    if os.path.exists(dst_path):
        shutil.copy2(dst_path, dst_path + ".backup")
        dst_data = load_json_like(dst_path, "configurations")
    else:
        dst_data = {"version": "0.2.0", "configurations": []}
    dst_cfgs = dst_data.get("configurations", [])
    dst_keys = {item.get("preLaunchTask") for item in dst_cfgs if item.get("preLaunchTask")}
    added = 0
    for entry in src_data.get("configurations", []):
        prelaunch = entry.get("preLaunchTask")
        if prelaunch and prelaunch in dst_keys:
            continue
        if not prelaunch and entry in dst_cfgs:
            continue
        dst_cfgs.append(entry)
        added += 1
    dst_data["configurations"] = dst_cfgs
    with open(dst_path, "w", encoding="utf-8") as handle:
        json.dump(dst_data, handle, indent=4)
    print(f"launch.json: added {added} configuration(s)")


def merge_tasks(src_path, dst_path):
    if not os.path.exists(src_path):
        return
    src_data = load_json_like(src_path, "tasks")
    if os.path.exists(dst_path):
        shutil.copy2(dst_path, dst_path + ".backup")
        dst_data = load_json_like(dst_path, "tasks")
    else:
        dst_data = {"version": "2.0.0", "tasks": []}
    dst_tasks = dst_data.get("tasks", [])
    dst_keys = {key_of(item) for item in dst_tasks if key_of(item)}
    added = 0
    for entry in src_data.get("tasks", []):
        entry_key = key_of(entry)
        if entry_key and entry_key in dst_keys:
            continue
        if not entry_key and entry in dst_tasks:
            continue
        dst_tasks.append(entry)
        added += 1
    dst_data["tasks"] = dst_tasks
    with open(dst_path, "w", encoding="utf-8") as handle:
        json.dump(dst_data, handle, indent=4)
    print(f"tasks.json: added {added} task(s)")


merge_launch(os.path.join(src_vscode, "launch.json"), os.path.join(dst_vscode, "launch.json"))
tasks_source = os.path.join(src_vscode, "tasks.json")
if not os.path.exists(tasks_source):
    tasks_source = os.path.join(src_vscode, "task.json")
merge_tasks(tasks_source, os.path.join(dst_vscode, "tasks.json"))
PY

echo "VS Code files merged successfully."