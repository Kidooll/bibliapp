import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<void> favoritar(String devotionalId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('user_favorite_devotionals').upsert({
      'user_id': userId,
      'devotional_id': devotionalId,
      'favorited_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> desfavoritar(String devotionalId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('user_favorite_devotionals')
        .delete()
        .match({'user_id': userId, 'devotional_id': devotionalId});
  }

  Future<List<String>> listarFavoritos() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final res = await _client
        .from('user_favorite_devotionals')
        .select('devotional_id')
        .eq('user_id', userId);

    return List<String>.from(res.map((e) => e['devotional_id']));
  }
}
