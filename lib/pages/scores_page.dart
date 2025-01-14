import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orchestra_app/pages/pdf_viewer_page.dart';
import 'package:orchestra_app/pages/profile_page.dart';
import 'package:orchestra_app/components/drawer.dart';
import 'package:orchestra_app/components/pdf_fetcher.dart';
import 'package:orchestra_app/components/pdf_downloader.dart';
import 'package:orchestra_app/components/scores_list.dart';
import 'package:orchestra_app/components/pdf_display.dart';

import '../components/scores_list.dart';
import '../helper/authentication_methods.dart';

class ScoresPage extends StatefulWidget {
  const ScoresPage({super.key});

  @override
  State<ScoresPage> createState() => _ScoresPageState();
}

class _ScoresPageState extends State<ScoresPage> {
  String? selectedPdf;
  List<String> pdfs = [];
  final currentUser = FirebaseAuth.instance.currentUser;
  final PDFFetcher pdfFetcher;
  final PDFDownloader pdfDownloader;
  bool _loading = true;
  bool _downloading = false;

  late AuthenticationMethods authenticationMethods;

  _ScoresPageState()
      : pdfFetcher = PDFFetcher(FirebaseAuth.instance.currentUser),
        pdfDownloader = PDFDownloader();

  @override
  void initState() {
    super.initState();
    authenticationMethods = AuthenticationMethods(context);
    _initPdfs();
  }

  _initPdfs() async {
    setState(() {
      _loading = true;
    });

    pdfs = await pdfFetcher.fetchPDFs();

    setState(() {
      _loading = false;
    });
  }


  Future<String> _downloadPdf(String pdfName) async {
    setState(() {
      _downloading = true; // Set downloading to true when starting the download
    });

    final userDocument = await FirebaseFirestore.instance.collection("Users").doc(currentUser?.email).get();
    final instrument = userDocument.data()?['Instrument'];
    String path = await pdfDownloader.downloadFile(pdfName, instrument!);

    setState(() {
      _downloading = false; // Set downloading to false when download is finished
    });

    return path;
  }

  void _onPdfSelected(String path) {
    setState(() {
      selectedPdf = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scores'),
      ),
      drawer: MyDrawer(
        onProfileTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
        onSignOut: authenticationMethods.logout,
        onScoresTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScoresPage())),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // Display loading circle when loading PDF list
          : Stack( // Using Stack widget
        children: <Widget>[
          pdfs.isEmpty
              ? const Center(child: Text("No scores")) // Display 'No scores' text
              : isLandscape
              ? Row(
            children: [
              Expanded(child: ScoresList(pdfs: pdfs, onPdfSelected: _onPdfSelected, onDownload: _downloadPdf)),
              if (selectedPdf != null) Expanded(child: PDFDisplay(path: selectedPdf!, key: ValueKey(selectedPdf))),
            ],
          )
              : ScoresList(pdfs: pdfs, onPdfSelected: _onPdfSelected, onDownload: _downloadPdf),
          if (_downloading) // Overlay when downloading
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.black12, // semi-transparent black for dark overlay
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

}
