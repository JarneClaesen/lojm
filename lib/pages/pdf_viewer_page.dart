import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:orchestra_app/components/pdf_display.dart';

class PdfViewerPage extends StatelessWidget {
  final String path;

  PdfViewerPage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
      ),
      body: PDFDisplay(path: path),
    );
  }
}
