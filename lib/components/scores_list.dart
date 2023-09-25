import 'package:flutter/material.dart';
import 'package:orchestra_app/pages/pdf_viewer_page.dart';

class ScoresList extends StatelessWidget {
  final List<String> pdfs;
  final Function(String) onPdfSelected;
  final Function(String) onDownload;

  ScoresList({required this.pdfs, required this.onPdfSelected, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pdfs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0), // increased horizontal padding
          child: InkWell(
            onTap: () async {
              final localPath = await onDownload(pdfs[index]);

              final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

              if (isLandscape) {
                print("Tapped on PDF: $localPath");
                onPdfSelected(localPath);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerPage(path: localPath),
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16), // increased padding for the container
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 28), // you can adjust the icon size if needed
                  SizedBox(width: 20), // increased spacing after the icon
                  Expanded(child: Text(pdfs[index], style: TextStyle(fontSize: 16))), // increased font size for the text
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
