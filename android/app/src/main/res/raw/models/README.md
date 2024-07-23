# Models
## Model Preparation

This app runs on the [Depth Anything V2](https://github.com/DepthAnything/Depth-Anything-V2), a PyTorch project. To run Depth Anything V2 (or V1) on a Hexagon NPU via SNPE, you must convert it to the appropriate format (.dlc).

1. Use [fabio-sim's tool](https://github.com/fabio-sim/Depth-Anything-ONNX) to convert the PyTorch model into ONNX format (dynamic input size)
2. Use `snpe-onnx-to-dlc` from the SNPE SDK to convert the .onnx output into a non-quantized .dlc file.

```bash
# Example using 256x256 image, adjust as needed
snpe-onnx-to-dlc -i depth_anything_v2_vits_dynamic.onnx --input_dim "image" 1,3,252,252
```
3. Rename files and copy to `android/app/src/main/res/raw/models` folder

## Naming Format
To make it easier to load and organize models, a special naming convention is used.

```bash
# model_version = depth_anything_v1 or depth_anything_v2
# encoder = vits (small) / vitb (base) / vitl (large) / vitg (giant)
# input_size = image input size (i.e. 252x252, must less than 518 and divisible by 14)
{model_version}_{encoder}_{input_size}.dlc

# Example: Depth Anything V2 - Small - 252x252
depth_anything_v2_vits_252.dlc
```