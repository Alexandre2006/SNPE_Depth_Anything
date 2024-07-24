import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snpe_depth_anything/widgets/model_config.dart';

class ModelLoadingScreen extends StatefulWidget {
  const ModelLoadingScreen(
      {super.key,
      required this.modelPath,
      required this.runtime,
      required this.performanceProfile});

  final String modelPath;
  final Runtime runtime;
  final PerformanceProfile performanceProfile;

  @override
  State<ModelLoadingScreen> createState() => _ModelLoadingScreenState();
}

class _ModelLoadingScreenState extends State<ModelLoadingScreen> {
  static const platform =
      MethodChannel('dev.thinkalex.snpe_depth_anything/model');

  bool hasError = false;

  @override
  void initState() {
    platform.invokeMethod("loadModel", {
      "modelPath": widget.modelPath,
      "runtime": widget.runtime.toString().split('.').last,
      "performanceProfile": widget.performanceProfile.toString().split('.').last
    }).catchError((error) {
      setState(() {
        print(error);
        hasError = true;
      });
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Text(
                        hasError ? "Loading Failed" : "Loading model...",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    hasError
                        ? Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: const Text(
                                  "An error occurred while loading the model!",
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, left: 8, right: 8),
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_back),
                                      Padding(
                                          padding: EdgeInsets.only(right: 8)),
                                      Text("Go back")
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(16),
                                  child: LinearProgressIndicator()),
                              Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Text("This can take a few seconds"),
                              ),
                            ],
                          )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
