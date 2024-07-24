import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:snpe_depth_anything/services/preprocessing.dart';

class CameraPreview extends StatefulWidget {
  const CameraPreview({super.key});

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  CameraController controller = CameraController(
    const CameraDescription(
      name: "Camera 1",
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 0,
    ),
    ResolutionPreset.high,
  );

  Image? latestResult;

  @override
  void initState() {
    controller.initialize().whenComplete(() {
      controller.startImageStream((image) {
        setState(() {
          // Image is 3-channel YUV420 - convert to 3-channel RGB
          (ByteBuffer, ByteBuffer, ByteBuffer) rgbImage = yuv420ToRGB(
            image.planes[0].bytes.buffer,
            image.planes[1].bytes.buffer,
            image.planes[2].bytes.buffer,
          );

          // Make prediction
        });
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    controller.stopImageStream();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Preview"),
      ),
      bottomNavigationBar: const BottomAppBar(),
      body: Center(
        child: latestResult ?? const Text("No result yet..."),
      ),
    );
  }
}
