# FlexViT Patch Documentation

## Overview
These scripts make FlexViT integrate into an existing SECDA-TFLite checkout with a single command:
- `flexvit_integration.sh` - copies the FlexViT source overlay into SECDA-TFLite and applies the VS Code merge step
- `patch_vscode.sh` - merges the FlexViT launch and task entries into SECDA-TFLite's `.vscode` folder

## What Gets Integrated
- `src/data` - model assets and local data files
- `src/hardware_automation` - generated bitstreams and hardware configuration files
- `src/src/secda_delegates/vit_delegate/v9` - the FlexViT delegate implementation and Bazel build files
- `src/src/tensorflow/launch.json` - launch configurations for the VIT delegate
- `src/src/tensorflow/tasks.json` - Bazel build tasks for the VIT delegate

## How It Works
- The integration script searches upward for a parent folder named `SECDA-TFLite`
- The FlexViT `src/` tree is overlaid into the SECDA-TFLite checkout without deleting unrelated files
- The VS Code patch helper merges new launch/task entries while preserving existing SECDA-TFLite configurations
- Existing destination VS Code files are backed up as `.backup` before they are rewritten

## Usage
```bash
cd <SECDA-TFLite>/FlexViT
chmod +x flexvit_integration.sh patch_vscode.sh
./flexvit_integration.sh
```

## Recovery
If you want to restore the previous VS Code state, copy the backup files back into place:
```bash
cp <SECDA-TFLite>/tensorflow/.vscode/launch.json.backup <SECDA-TFLite>/tensorflow/.vscode/launch.json
cp <SECDA-TFLite>/tensorflow/.vscode/tasks.json.backup <SECDA-TFLite>/tensorflow/.vscode/tasks.json
```
