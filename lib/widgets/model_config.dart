import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModelConfigurationWidget extends StatefulWidget {
  const ModelConfigurationWidget({super.key, required this.controller});
  final ModelConfigurationController controller;

  @override
  State<ModelConfigurationWidget> createState() =>
      _ModelConfigurationWidgetState();
}

class _ModelConfigurationWidgetState extends State<ModelConfigurationWidget> {
  // 3 Rows
  // Row 1: Model Version
  // Row 2: Encoder + Size
  // Row 3: Runtime + Performance Profile
  // Optionally: Model Path at bottom as text

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: "Model Version"),
                  isExpanded: true,
                  icon: const Icon(Icons.view_in_ar),
                  value: widget.controller.modelVersion,
                  hint: const Text("Select Model Version"),
                  disabledHint: const Text("No Models Available"),
                  items: widget.controller
                      .getAvailableModelVersions()
                      .map((ModelVersion modelVersion) {
                    return DropdownMenuItem(
                      value: modelVersion,
                      child: Text(
                          "Depth Anything ${modelVersion.toString().split(".").last}"),
                    );
                  }).toList(),
                  onChanged: (ModelVersion? value) {
                    setState(() {
                      widget.controller.modelVersion = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 8.0)),
          Row(
            children: [
              // Encoder
              Expanded(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: "Encoder"),
                  isExpanded: true,
                  icon: const Icon(Icons.qr_code_2),
                  value: widget.controller.encoder,
                  hint: const Text("Select Encoder"),
                  disabledHint: const Text("Unavailable"),
                  items: widget.controller
                      .getAvailableEncoders()
                      .map((Encoder encoder) {
                    return DropdownMenuItem(
                      value: encoder,
                      child: Text(encoder.toString().split(".").last),
                    );
                  }).toList(),
                  onChanged: (Encoder? value) {
                    setState(() {
                      widget.controller.encoder = value;
                    });
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 8.0)),
              // Size
              Expanded(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: "Input Size"),
                  isExpanded: true,
                  icon: const Icon(Icons.photo_size_select_large),
                  value: widget.controller.size,
                  hint: const Text("Select Size"),
                  disabledHint: const Text("Unavailable"),
                  items: widget.controller.getAvailableSizes().map((int size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text("$size x $size"),
                    );
                  }).toList(),
                  onChanged: (int? value) {
                    setState(() {
                      widget.controller.size = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 8.0)),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: "Runtime"),
                  isExpanded: true,
                  value: widget.controller.runtime,
                  icon: const Icon(Icons.memory),
                  hint: const Text("Select Runtime"),
                  items: const [
                    DropdownMenuItem(
                      value: Runtime.cpu,
                      child: Text("CPU"),
                    ),
                    DropdownMenuItem(
                      value: Runtime.gpu,
                      child: Text("GPU"),
                    ),
                    DropdownMenuItem(
                      value: Runtime.gpuFloat16,
                      child: Text("GPU FP16"),
                    ),
                    DropdownMenuItem(
                      value: Runtime.dsp,
                      child: Text("DSP"),
                    ),
                  ],
                  onChanged: (Runtime? value) {
                    setState(() {
                      widget.controller.runtime = value!;
                    });
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.only(left: 8.0)),
              Expanded(
                child: DropdownButtonFormField(
                  decoration:
                      const InputDecoration(labelText: "Performance Profile"),
                  isExpanded: true,
                  value: widget.controller.performanceProfile,
                  icon: const Icon(Icons.speed),
                  items: PerformanceProfile.values
                      .map((PerformanceProfile profile) {
                    return DropdownMenuItem(
                      value: profile,
                      child: Text(performanceProfileNames[profile]!),
                    );
                  }).toList(),
                  onChanged: (PerformanceProfile? value) {
                    setState(() {
                      widget.controller.performanceProfile = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Model Configuration Controller
class ModelConfigurationController {
  static const platform =
      MethodChannel('dev.thinkalex.snpe_depth_anything/model');

  List<String> models = [
    "depth_anything_v2_vits_224.dlc",
    "depth_anything_v2_vitb_384.dlc",
    "depth_anything_v1_vits_224.dlc",
  ];

  // Configuration (final)
  String? _modelPath;
  Runtime _runtime = Runtime.cpu;
  PerformanceProfile _performanceProfile = PerformanceProfile.snpeDefault;

  // Configuration (selected options)
  ModelVersion? _modelVersion;
  Encoder? _encoder;
  int? _size;

  set encoder(Encoder? value) {
    if (value == null) {
      _encoder == null;
      _size = null;
      return;
    }

    // Check if size is still available
    if (_size != null && !isSizeAvailable(_modelVersion!, value)) {
      _size = null;
    }

    _encoder = value;

    // Notify Listeners
    _notifyPropertiesListeners();

    // Update Model Path
    updateModelPath();
  }

  set modelVersion(ModelVersion? value) {
    if (value == null) {
      _modelVersion = null;
      _encoder = null;
      _size = null;
      return;
    }
    _modelVersion = value;

    // Check if encoder is still available
    if (_encoder != null && !isEncoderAvailable(value)) {
      _encoder = null;
      _size = null;
      return;
    }

    // Check if size is still available
    if (_size != null && !isSizeAvailable(value, _encoder!)) {
      _size = null;
    }

    // Notify Listeners
    _notifyPropertiesListeners();

    // Update Model Path
    updateModelPath();
  }

  set size(int? value) {
    _size = value;

    // Notify Listeners
    _notifyPropertiesListeners();

    // Update Model Path
    updateModelPath();
  }

  void updateModelPath() {
    if (_modelVersion == null || _encoder == null || _size == null) {
      _modelPath = null;
    } else {
      // Filter by model
      List<String> modelFilter = models
          .where((element) =>
              element.contains(_modelVersion.toString().split(".").last))
          .toList();

      // Filter by encoder
      List<String> encoderFilter = modelFilter
          .where((element) =>
              element.contains(_encoder.toString().split(".").last))
          .toList();

      // Filter by size
      List<String> sizeFilter = encoderFilter
          .where((element) => element.contains(_size.toString()))
          .toList();

      _modelPath = sizeFilter.first;
    }

    _notifyPathListeners();
  }

  set runtime(Runtime value) {
    _runtime = value;
  }

  set performanceProfile(PerformanceProfile value) {
    _performanceProfile = value;
  }

  // Getters
  ModelVersion? get modelVersion => _modelVersion;
  Encoder? get encoder => _encoder;
  int? get size => _size;
  Runtime get runtime => _runtime;
  PerformanceProfile get performanceProfile => _performanceProfile;
  String? get modelPath => _modelPath;

  // Available Options
  List<ModelVersion> getAvailableModelVersions() {
    List<ModelVersion> availableModels = [];
    if (models.any((element) => element.contains("v1"))) {
      availableModels.add(ModelVersion.v1);
    }
    if (models.any((element) => element.contains("v2"))) {
      availableModels.add(ModelVersion.v2);
    }

    return availableModels;
  }

  List<Encoder> getAvailableEncoders() {
    // Filter by model
    List<String> modelFilter = models
        .where((element) =>
            element.contains(_modelVersion.toString().split(".").last))
        .toList();

    List<Encoder> availableEncoders = [];
    if (modelFilter.any((element) => element.contains("vits"))) {
      availableEncoders.add(Encoder.vits);
    }
    if (modelFilter.any((element) => element.contains("vitb"))) {
      availableEncoders.add(Encoder.vitb);
    }
    if (modelFilter.any((element) => element.contains("vitl"))) {
      availableEncoders.add(Encoder.vitl);
    }
    if (modelFilter.any((element) => element.contains("vitg"))) {
      availableEncoders.add(Encoder.vitg);
    }

    return availableEncoders;
  }

  List<int> getAvailableSizes() {
    // Filter by model
    List<String> modelFilter = models
        .where((element) =>
            element.contains(_modelVersion.toString().split(".").last))
        .toList();

    // Filter by encoder
    List<String> encoderFilter = modelFilter
        .where(
            (element) => element.contains(_encoder.toString().split(".").last))
        .toList();

    List<int> availableSizes = [];
    for (String element in encoderFilter) {
      String withoutExtension = element.split('.').first;
      int? size = int.tryParse(withoutExtension.split('_').last);
      if (size != null) {
        availableSizes.add(size);
      }
    }

    return availableSizes;
  }

  // Validators
  bool isEncoderAvailable(ModelVersion newModel) {
    // Filter all models with the current model
    List<String> modelFilter = models
        .where(
            (element) => element.contains(newModel.toString().split(".").last))
        .toList();

    // Filter models with the current encoder
    List<String> encoderFilter = modelFilter
        .where(
            (element) => element.contains(_encoder.toString().split(".").last))
        .toList();

    return encoderFilter.isNotEmpty;
  }

  bool isSizeAvailable(ModelVersion newModel, Encoder newEncoder) {
    // Filter all models with the current encoder
    List<String> encoderFilter = models
        .where((element) =>
            element.contains(newEncoder.toString().split(".").last))
        .toList();

    // Filter models with the current model
    List<String> modelFilter = encoderFilter
        .where(
            (element) => element.contains(newModel.toString().split(".").last))
        .toList();

    // Filter models with the current size
    List<String> sizeFilter = modelFilter
        .where((element) => element.contains(_size.toString()))
        .toList();

    return sizeFilter.isNotEmpty;
  }

  // Channel Methods
  Future<void> getAvailableModels() async {
    models = (await platform.invokeListMethod<String>("getAvailableModels"))!;
  }

  // Listeners
  List<VoidCallback> _propertiesListeners = [];
  List<VoidCallback> _pathListeners = [];

  void addPropertiesListener(VoidCallback listener) {
    _propertiesListeners.add(listener);
  }

  void removePropertiesListener(VoidCallback listener) {
    _propertiesListeners.remove(listener);
  }

  void addPathListener(VoidCallback listener) {
    _pathListeners.add(listener);
  }

  void removePathListener(VoidCallback listener) {
    _pathListeners.remove(listener);
  }

  void _notifyPropertiesListeners() {
    for (VoidCallback listener in _propertiesListeners) {
      listener();
    }
  }

  void _notifyPathListeners() {
    for (VoidCallback listener in _pathListeners) {
      listener();
    }
  }
}

// Enums
enum ModelVersion { v1, v2 }

enum Encoder { vits, vitb, vitl, vitg }

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

Map<PerformanceProfile, String> performanceProfileNames = {
  PerformanceProfile.burst: "Burst",
  PerformanceProfile.highPerformance: "High Performance",
  PerformanceProfile.sustainedHighPerformance: "Sustained High Performance",
  PerformanceProfile.balanced: "Balanced",
  PerformanceProfile.lowBalanced: "Low Balanced",
  PerformanceProfile.lowPowerSaver: "Low Power Saver",
  PerformanceProfile.powerSaver: "Power Saver",
  PerformanceProfile.highPowerSaver: "High Power Saver",
  PerformanceProfile.extremePowerSaver: "Extreme Power Saver",
  PerformanceProfile.snpeDefault: "SNPE Default",
  PerformanceProfile.systemDefault: "System Default",
};
