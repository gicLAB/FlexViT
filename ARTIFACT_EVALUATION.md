# Artifact Evaluation

To reproduce the results presented in our FPL 2026 paper, reviewers should evaluate the provided INT8 quantized models using the deployed hardware bitstream.

## Provided Models

We evaluate five representative Vision Transformer architectures. The pre-converted INT8 `.tflite` models are included in `src/data/models`:
- ViT-T (ImageNet-21k) sourced from [tensorflow-image-models](https://github.com/martinsbruveris/tensorflow-image-models)
- DeiT-T (ImageNet-1k) sourced from [tensorflow-image-models](https://github.com/martinsbruveris/tensorflow-image-models)
- Swin-T (ImageNet-1k) sourced from [tensorflow-image-models](https://github.com/martinsbruveris/tensorflow-image-models)
- MobileViT-S (ImageNet-1k) sourced from [timm/mobilevit_s.cvnets_in1k](https://huggingface.co/timm/mobilevit_s.cvnets_in1k)
- EfficientViT-b1 (ImageNet-1k) sourced from [timm/efficientvit_b1.r224_in1k](https://huggingface.co/timm/efficientvit_b1.r224_in1k)

## Functional Correctness

Before benchmarking, verify that the hardware executes the model accurately. Run the model through the hardware using the `id_vit_delegate_9` configuration. The inference outputs produced by the hardware accelerator must match the software execution outputs within TFLite's acceptable passing range (cosine similarity > 99%).

## Latency Evaluation

To measure end-to-end and layer-specific speedups, run the models using the `bm_vit_delegate_9` configuration.
- CPU Baseline: Execute the inference strictly on the ARM Cortex-A9 CPU with NEON SIMD instructions enabled.
- Hardware Accelerated: Execute using the FlexViT delegate and the `VIT_9_0.bit` bitstream clocked at 200MHz.
- All latency metrics should be averaged over 100 inference runs to account for system variance.

## Energy Evaluation

Energy per inference (Joules) is measured externally using a Makerfocus USB power meter connected to the PYNQ-Z2 board.

For CPU baseline measurements, configure the FPGA with the minimal baseline bitstream (`CPU_1_0.bit`) rather than the full FlexViT bitstream.

Record the power draw and multiply it by the measured latency, averaged over 100 runs, for both the CPU baseline and the CPU+accelerator executions.

## Resource Utilization

The FPGA resource utilization (BRAM, DSP, FF, LUT) can be verified by inspecting the Vivado synthesis and implementation reports generated alongside the `.bit` files.