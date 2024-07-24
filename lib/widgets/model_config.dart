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

  List<String> models = [];

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
          .where((element) => element.contains(_modelVersion.toString()))
          .toList();

      // Filter by encoder
      List<String> encoderFilter = modelFilter
          .where((element) => element.contains(_encoder.toString()))
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
    if (models.any((element) => element.contains(ModelVersion.v1.toString()))) {
      availableModels.add(ModelVersion.v1);
    }
    if (models.any((element) => element.contains(ModelVersion.v2.toString()))) {
      availableModels.add(ModelVersion.v2);
    }

    return availableModels;
  }

  List<Encoder> getAvailableEncoders() {
    // Filter by model
    List<String> modelFilter = models
        .where((element) => element.contains(_modelVersion.toString()))
        .toList();

    List<Encoder> availableEncoders = [];
    if (modelFilter
        .any((element) => element.contains(Encoder.vits.toString()))) {
      availableEncoders.add(Encoder.vits);
    }
    if (modelFilter
        .any((element) => element.contains(Encoder.vitb.toString()))) {
      availableEncoders.add(Encoder.vitb);
    }
    if (modelFilter
        .any((element) => element.contains(Encoder.vitl.toString()))) {
      availableEncoders.add(Encoder.vitl);
    }
    if (modelFilter
        .any((element) => element.contains(Encoder.vitg.toString()))) {
      availableEncoders.add(Encoder.vitg);
    }

    return availableEncoders;
  }

  List<int> getAvailableSizes() {
    // Filter by model
    List<String> modelFilter = models
        .where((element) => element.contains(_modelVersion.toString()))
        .toList();

    // Filter by encoder
    List<String> encoderFilter = modelFilter
        .where((element) => element.contains(_encoder.toString()))
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
        .where((element) => element.contains(newModel.toString()))
        .toList();

    // Filter models with the current encoder
    List<String> encoderFilter = modelFilter
        .where((element) => element.contains(_encoder.toString()))
        .toList();

    return encoderFilter.isNotEmpty;
  }

  bool isSizeAvailable(ModelVersion newModel, Encoder newEncoder) {
    // Filter all models with the current encoder
    List<String> encoderFilter = models
        .where((element) => element.contains(newEncoder.toString()))
        .toList();

    // Filter models with the current model
    List<String> modelFilter = encoderFilter
        .where((element) => element.contains(newModel.toString()))
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
