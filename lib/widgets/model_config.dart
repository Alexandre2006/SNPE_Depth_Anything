import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModelConfigurationWidget extends StatefulWidget {
  const ModelConfigurationWidget({super.key});

  @override
  State<ModelConfigurationWidget> createState() =>
      _ModelConfigurationWidgetState();
}

class _ModelConfigurationWidgetState extends State<ModelConfigurationWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// Model Configuration Controller
class ModelConfigurationController {
  static const platform =
      MethodChannel('dev.thinkalex.snpe_depth_anything/model');

  // Configuration
  final ValueNotifier<String> _modelPath = ValueNotifier<String>('');
  final ValueNotifier<Runtime> _runtime = ValueNotifier<Runtime>(Runtime.cpu);
  final ValueNotifier<PerformanceProfile> _performanceProfile =
      ValueNotifier<PerformanceProfile>(PerformanceProfile.snpeDefault);

  // Configuration - Getters
  String get modelPath => _modelPath.value;
  String get modelName =>
      modelPath.contains("v2") ? "Depth Anything v2" : "Depth Anything v1";
  int get modelInputSize => int.parse(modelPath.split(".")[0].split("_").last);
  // second to last element of the model path
  String get modelEncoder =>
      modelPath.split(".")[0].split("_").reversed.toList()[1];
  Runtime get runtime => _runtime.value;
  PerformanceProfile get performanceProfile => _performanceProfile.value;

  // Configuration - Setters
  set modelPath(String value) {
    _modelPath.value = value;
    _notifyListeners();
  }

  set modelName(String value) {
    if (value == "Depth Anything v2") {
      modelPath = "depth_anything_v2_${modelEncoder}_256.dlc";
    } else {
      modelPath = "depth_anything_v1_${modelEncoder}_256.dlc";
    }
  }

  set modelInputSize(int value) {
    // Replace input size in current model path
    final modelPathParts = modelPath.split(".")[0].split("_");
    modelPathParts[modelPathParts.length - 1] = value.toString();
    _modelPath.value = "${modelPathParts.join("_")}.dlc";
  }

  set modelEncoder(String value) {
    // Replace encoder in current model path
    final modelPathParts = modelPath.split("_");
    modelPathParts[modelPathParts.length - 2] = value;
    _modelPath.value = modelPathParts.join("_");
  }

  // Listeners
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notify Listeners
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

enum Runtime { cpu, gpu, gpuFloat16, dsp }

enum PerformanceProfile {
  //    // High Performance
  burst, // Fastest (not intended for continuous use)
  highPerformance,
  sustainedHighPerformance, // Fastest (intended for continuous use)

  // Balanced
  balanced,
  lowBalanced,

  // Power Saving
  lowPowerSaver,
  powerSaver,
  highPowerSaver,
  extremePowerSaver, // Most Efficient

  // Defaults
  snpeDefault, // Default (from SNPE library)
  systemDefault, // Default (based on system settings)
}
