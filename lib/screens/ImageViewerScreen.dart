import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  final File imageFile;

  const ImageViewerScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("License Preview")),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(imageFile),
        ),
      ),
    );
  }
}
