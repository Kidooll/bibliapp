// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// services/firestore_service.dart
class FirestoreService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Buscar todos os estudos
  Stream<QuerySnapshot> getEstudos() {
    print('Buscando estudos no Firestore...'); // Debug
    return _firestore
        .collection('estudos')
        .orderBy('title', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Dados recebidos do Firestore: ${snapshot.docs.map((doc) {
        final data = doc.data();
        print('Documento ${doc.id}: $data'); // Debug de cada documento
        return data;
      }).toList()}');
      return snapshot;
    });
  }
}
