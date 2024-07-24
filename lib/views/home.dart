import 'package:flutter/material.dart';
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

    // TODO: implement initState
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
              children: [
                ModelConfigurationWidget(controller: controller),
                ModelLoadButton(isEnabled: controller.modelPath != null)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
