# FlexViT: A Flexible FPGA-based Accelerator for Edge Vision Transformers

This repository contians the code for the FlexViT paper, accepted at [FPL 2026](https://2026.fpl.org).

## Steps:
### 1. Download SECDA-TFLite v2.
```bash 
git clone https://github.com/gicLAB/SECDA-TFLite.git && \
cd SECDA-TFLite && \
git submodule init && \
git submodule update && \
sudo apt install -y jq ssh rsync
```

### 2. Download the FlexViT Repo in the SECDA-TFLite v2 path.

Clone FlexViT inside the SECDA-TFLite checkout so the repository ends up at `<SECDA-TFLite>/FlexViT`.
```bash
cd <SECDA-TFLite-root> && \
git clone https://github.com/gicLAB/FlexViT.git FlexViT && \
cd FlexViT && \
chmod +x flexvit_integration.sh patch_vscode.sh
```

### 3. Setup SECDA-TFLite v2.

Now go to  [https://github.com/gicLAB/SECDA-TFLite.git](https://github.com/gicLAB/SECDA-TFLite.git) to complete the set up of SECDA-TFLite.
- Start from "Configuring SECDA-TFLite"
- Use the Dev Container Methods (2.A) of VSCode to set up the development environment.
- Verify that you can run SECDA-TFLite v2 for vm/v5 accelerator, **simulation, hardware automation and secda_apps_evaluation_suite** for Pynq-Z2  board before integrating FlexViT
- If you face any issues setting up SECDA-TFLite v2, please create an issue in the SECDA-TFLite repository.

### 4. FlexViT Integration Steps
```bash
cd <SECDA-TFLite-root>/FlexViT && \
./flexvit_integration.sh
```

### 5. Hardware Generation
- In 'FlexViT/src/hardware_automation/generated', we have included the related bitstream files for FlexViT.
- To generate an FPGA bitstream outside ***outside of the Dev-Container*** please follow SECDA-TFLite [hardware_automation](https://github.com/gicLAB/SECDA-TFLite/tree/main/hardware_automation).

### 6. Run on Simulation

- Make sure you open the SECDA-TFLite workspace in VS Code first: `File -> Open Workspace from File -> SECDA-TFLite.code-workspace`. Otherwise, you will not see the appropriate options in "Run and Debug".

- Within the VSCODE 'run and debug' the user should be presented with two key applications per accelerator version:
  - Benchmark Model : run a Model on an Accelerator to understand execution time layer by layer.
  - Inference Diff : Verify the correctness of the accelerator on against CPU execution for a Model.

- Select either from the dropDown Menu and "Run" to simulate.

- In order to change the model being run, open `src/tensorflow/launch.json` and edit the `--model_file` or `--graph` entry for the accelerator you are using.
  
- Keep only one model line uncommented. For example, in the VITv9 launch configs you can switch between:
  ```json
  --model_file=${workspaceFolder}/../data/models/vit_tiny_patch16_224.tflite,
  // --model_file=${workspaceFolder}/../data/models/deit_tiny_patch16_224.tflite,
  // --model_file=${workspaceFolder}/../data/models/mobilevit_s_int8.tflite,
  // --model_file=${workspaceFolder}/../data/models/efficientvit_int8.tflite,
  // --model_file=${workspaceFolder}/../data/models/Swin-T_INT8.tflite,
  ```
- The same pattern applies to the benchmark launch config, where the model path is set with `--graph=` instead of `--model_file=`.

### 7. Run on FPGA

- These FPGA run commands are not part of the FlexViT repository.
- After running `./flexvit_integration.sh` inside the SECDA-TFLite workspace, use SECDA-TFLite's own `src/secda_apps_evaluation_suite` flows and launch configurations to run the benchmark, image classification, and evaluation tasks on the board.
- FlexViT only provides the delegate, hardware assets, and VS Code integration needed for those SECDA-TFLite tasks to pick up the VIT accelerator.

### FlexViT Folder Structure:
```text
|-- flexvit_integration.sh
|-- patch_vscode.sh
|-- README_Patch.md
|-- ARTIFACT_EVALUATION.md
|-- figures/
|-- src/
|   |-- data/
|   |-- hardware_automation/
|   |-- src/
|   |-- tensorflow/
```

## Artifact Evaluation

The paper-specific model list and reproduction notes are documented in [ARTIFACT_EVALUATION.md](ARTIFACT_EVALUATION.md). That file summarizes the provided INT8 models and the evaluation flow used for correctness, latency, energy, and resource reporting.


## Cite:
```bibtex
@inproceedings{dymarkowski2026flexvit,
  author    = {Dymarkowski, Hubert and Fu, Xingjian and Saha, Rappy and Haris, Jude and Cano, Jose},
  title     = {FlexViT: A Flexible FPGA-based Accelerator for Edge Vision Transformers},
  booktitle = {36th International Conference on Field-Programmable Logic and Applications (FPL)},
  year      = {2026},
  month     = {September},
  address   = {Ghent, Belgium},
  note      = {Accepted for Publication}
}
```
