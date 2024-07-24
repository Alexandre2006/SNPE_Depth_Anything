import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snpe_depth_anything/views/model_loader.dart';
import 'package:snpe_depth_anything/widgets/model_button.dart';
import 'package:snpe_depth_anything/widgets/model_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ModelConfigurationController controller = ModelConfigurationController();
  @override
  void initState() {
    // Scan for models
    controller.getAvailableModels().whenComplete(() => setState(() {}));

    // Add callback for path changes
    controller.addPathListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SNPE Depth Anything"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModelConfigurationWidget(controller: controller),
                ModelLoadButton(
                  isEnabled: controller.modelPath != null,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModelLoadingScreen(
                          modelPath: controller.modelPath!,
                          runtime: controller.runtime,
                          performanceProfile: controller.performanceProfile,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
