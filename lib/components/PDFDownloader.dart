import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class PDFDownloader {
  Future<String> downloadFile(String pdfName, String instrument) async {
    final Directory tempDir = Directory.systemTemp;
    final File tempFile = File('${tempDir.path}/$pdfName');

    if (await tempFile.exists()) {
      return tempFile.path;
    } else {
      final Reference ref = FirebaseStorage.instance.ref('$instrument/$pdfName');
      await ref.writeToFile(tempFile);
      return tempFile.path;
    }
  }
}