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

  Future<List<Map<String, dynamic>>> listarNotasDoUsuario() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('bookmarks')
        .select()
        .eq('user_id', userId)
        .eq('bookmark_type', 'note')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> criarOuAtualizarNota({
    required String? id,
    required String noteText,
    required String highlightColor,
    List<int>? verseIds,
    bool isFavorite = false,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final data = <String, dynamic>{
      'user_id': userId,
      'bookmark_type': 'note',
      'note_text': noteText,
      'highlight_color': highlightColor.isNotEmpty ? highlightColor : null,
      'is_favorite': isFavorite,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Add id if it's an update
    if (id != null) {
      data['id'] = id;
    }

    // Add verse_ids if provided
    if (verseIds != null && verseIds.isNotEmpty) {
      data['verse_ids'] = verseIds;
    }

    // Se for uma atualização, mantém a data de criação original
    if (id == null) {
      data['created_at'] = DateTime.now().toIso8601String();
    }

    await _client.from('bookmarks').upsert(data);
  }

  Future<void> deletarNota(String noteId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('bookmarks').delete().match({
      'id': noteId,
      'user_id': userId,
    });
  }

  Future<void> favoritarNota(String noteId, bool favorito) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('bookmarks').update({
      'is_favorite': favorito,
    }).match({
      'id': noteId,
      'user_id': userId,
    });
  }
}
