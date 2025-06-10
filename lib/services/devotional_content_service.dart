import 'package:supabase_flutter/supabase_flutter.dart';

class DevotionalContentService {
  final _client = Supabase.instance.client;

  // Get today's devotional
  Future<Map<String, dynamic>?> getDailyDevotional() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      print('Buscando devocional para a data: ${today.toIso8601String()}');

      final response = await _client
          .from('devotionals')
          .select()
          .lte('published_date', today.toIso8601String())
          .order('published_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        print('Devocional encontrado: ${response['id']}');
        print('Dados completos do devocional: $response');
        return Map<String, dynamic>.from(response);
      }
      print('Nenhum devocional encontrado para hoje');
      return null;
    } catch (e) {
      print('Erro ao buscar devocional diário: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Get a specific devotional by ID
  Future<Map<String, dynamic>?> getDevotionalById(String id) async {
    try {
      final response =
          await _client.from('devotionals').select().eq('id', id).maybeSingle();

      if (response != null) {
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e) {
      print('Error fetching devotional by ID: $e');
      return null;
    }
  }
}
