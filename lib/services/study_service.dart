import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class StudyService extends ChangeNotifier {
  final _client = Supabase.instance.client;

  // Buscar todos os estudos
  Future<List<Map<String, dynamic>>> getEstudos() async {
    try {
      final response = await _client
          .from('studies')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar estudos no Supabase: $e');
      return [];
    }
  }

  // Buscar um estudo específico pelo ID
  Future<Map<String, dynamic>?> getEstudoById(String id) async {
    try {
      final response = await _client
          .from('studies')
          .select()
          .eq('id', id)
          .single();

      return response;
    } catch (e) {
      print('Erro ao buscar estudo no Supabase: $e');
      return null;
    }
  }
  
  // Favoritar um estudo
  Future<void> favoritarEstudo(String studyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('user_favorite_studies').upsert({
      'user_profile_id': userId,
      'study_id': studyId,
      'favorited_at': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  // Desfavoritar um estudo
  Future<void> desfavoritarEstudo(String studyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('user_favorite_studies')
        .delete()
        .match({'user_profile_id': userId, 'study_id': studyId});
    notifyListeners();
  }

  // Verificar se um estudo está favoritado
  Future<bool> isEstudoFavoritado(String studyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _client
        .from('user_favorite_studies')
        .select()
        .match({'user_profile_id': userId, 'study_id': studyId});

    return response.isNotEmpty;
  }

  // Marcar estudo como lido
  Future<void> marcarEstudoComoLido(String studyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('user_read_studies').upsert({
      'user_profile_id': userId,
      'study_id': studyId,
      'read_at': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  // Verificar se um estudo foi lido
  Future<bool> isEstudoLido(String studyId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _client
        .from('user_read_studies')
        .select()
        .match({'user_profile_id': userId, 'study_id': studyId});

    return response.isNotEmpty;
  }
}