import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatelessWidget {
  final File file;

  const PdfViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("License Preview")),
      body: PDFView(
        filePath: file.path,
        autoSpacing: true,
        swipeHorizontal: false,
        pageFling: true,
      ),
    );
  }
}
