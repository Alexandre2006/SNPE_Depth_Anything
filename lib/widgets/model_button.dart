import 'package:flutter/material.dart';

class ModelLoadButton extends StatelessWidget {
  const ModelLoadButton({super.key, required this.isEnabled});
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      // Primary button
      onPressed: isEnabled ? () {} : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isEnabled ? Text("Run Model") : Text("Model Unavailable"),
          isEnabled ? Icon(Icons.play_arrow) : Icon(Icons.do_not_disturb)
        ],
      ),
    );
  }
}
