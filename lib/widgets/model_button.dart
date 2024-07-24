import 'package:flutter/material.dart';

class ModelLoadButton extends StatelessWidget {
  const ModelLoadButton(
      {super.key, required this.isEnabled, required this.onPressed});
  final bool isEnabled;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FilledButton(
        // Primary button
        onPressed: isEnabled ? () => onPressed() : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isEnabled
                ? const Text("Run Model")
                : const Text("Model Unavailable"),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0)),
            isEnabled
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.do_not_disturb)
          ],
        ),
      ),
    );
  }
}
