import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:orchestra_app/components/pdf_display.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io';

import '../helper/operation_status_code.dart';

class PdfViewerPage extends StatefulWidget {
  final String path;

  PdfViewerPage({required this.path});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {

  Future<OperationStatusCode> createLocalBackupFile(String filePath) async {
    try {
      if (!await FlutterFileDialog.isPickDirectorySupported()) {
        throw Exception("Picking directory not supported");
      }

      final pickedDirectory = await FlutterFileDialog.pickDirectory();

      if (pickedDirectory != null) {
        final fileData = File(filePath).readAsBytesSync();
        final fileName = filePath.split('/').last;

        await FlutterFileDialog.saveFileToDirectory(
          directory: pickedDirectory,
          data: fileData,
          mimeType: "application/pdf",
          fileName: fileName,
          replace: false,
        );

        return OperationStatusCode.success;
      }
      return OperationStatusCode.undefined;
    } catch (exc) {
      print(exc.toString());
      return OperationStatusCode.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: () async {
              OperationStatusCode status = await createLocalBackupFile(widget.path);
              if (status == OperationStatusCode.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF successfully downloaded!')));
              } else if (status == OperationStatusCode.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error downloading PDF.')));
              }
            },
          ),
        ],
      ),
      body: PDFDisplay(path: widget.path),
    );
  }
}



// If your app download files like pdf in storage then in 13 no permission is required for your application directory ask for getApplicationDocumentDirectory using path_provider and save your file in app directory then create download page in your app and using builder list all files available in given storage and give button to open file (you can use open_file):