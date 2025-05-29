// services/firebase.dart
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class FirebaseDevotionalService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>?> getDailyDevotional() async {
    try {
      final now = DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(now); // Formato 2025-05-13
      
      // Nova estrutura direta sob a data
      final devotionalPath = 'devocionais/$dateKey';
      
      final snapshot = await _dbRef.child(devotionalPath).get();
      
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar devocional: $e');
      return null;
    }
  }
}