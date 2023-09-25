import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PDFFetcher {
  final User? currentUser;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  PDFFetcher(this.currentUser);

  Future<List<String>> fetchPDFs() async {
    List<String> pdfs = [];
    if (currentUser == null) return pdfs;

    final userDocument = await usersCollection.doc(currentUser?.email).get();
    final instrument = userDocument.data()?['Instrument'];

    final ListResult result = await FirebaseStorage.instance.ref('$instrument/').list();
    pdfs = result.items.map((ref) => ref.name).toList();

    return pdfs;
  }
}