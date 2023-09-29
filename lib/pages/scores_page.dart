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

//todo: add a loading circle when downloading pdfs

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
    pdfs = await pdfFetcher.fetchPDFs();
    setState(() {});
  }

  Future<String> _downloadPdf(String pdfName) async {
    final userDocument = await FirebaseFirestore.instance.collection("Users").doc(currentUser?.email).get();
    final instrument = userDocument.data()?['Instrument'];
    return await pdfDownloader.downloadFile(pdfName, instrument!);
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
      body: isLandscape
          ? Row(
        children: [
          Expanded(child: ScoresList(pdfs: pdfs, onPdfSelected: _onPdfSelected, onDownload: _downloadPdf)),
          if (selectedPdf != null) Expanded(child: PDFDisplay(path: selectedPdf!, key: ValueKey(selectedPdf))),
        ],
      )
          : ScoresList(pdfs: pdfs, onPdfSelected: _onPdfSelected, onDownload: _downloadPdf),
    );
  }
}
