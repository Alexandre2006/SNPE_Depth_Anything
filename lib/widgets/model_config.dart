import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModelConfigurationWidget extends StatefulWidget {
  const ModelConfigurationWidget({super.key});

  @override
  State<ModelConfigurationWidget> createState() =>
      _modelConfigurationWidgetState();
}

class _modelConfigurationWidgetState extends State<ModelConfigurationWidget> {
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
  String? modelPath;
  Runtime runtime = Runtime.cpu;
  PerformanceProfile performanceProfile = PerformanceProfile.snpeDefault;

  // Configuration (selected options)
  ModelVersion? _modelVersion;
  Encoder? _encoder;
  int? size;

  set encoder(Encoder? value) {
    if (value == null) {
      _encoder == null;
      size = null;
      return;
    }

    // Check if size is still available
    if (size != null && !isSizeAvailable(_modelVersion!, value)) {
      size = null;
    }
  }

  set modelVersion(ModelVersion? value) {
    if (value == null) {
      _modelVersion = null;
      _encoder = null;
      size = null;
      return;
    }
    _modelVersion = value;

    // Check if encoder is still available
    if (_encoder != null && !isEncoderAvailable(value)) {
      _encoder = null;
      size = null;
      return;
    }

    // Check if size is still available
    if (size != null && !isSizeAvailable(value, _encoder!)) {
      size = null;
    }
  }

  // Getters
  ModelVersion? get modelVersion => _modelVersion;
  Encoder? get encoder => _encoder;

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
        .where((element) => element.contains(size.toString()))
        .toList();

    return sizeFilter.isNotEmpty;
  }

  // Channel Methods
  Future<void> getAvailableModels() async {
    models = (await platform.invokeListMethod<String>("getAvailableModels"))!;
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
