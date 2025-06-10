import 'package:supabase_flutter/supabase_flutter.dart';

class DevotionalContentService {
  final _client = Supabase.instance.client;

  // Get today's devotional
  Future<Map<String, dynamic>?> getDailyDevotional() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final response = await _client
          .from('devotionals')
          .select()
          .lte('published_date', today.toIso8601String())
          .order('published_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e) {
      print('Error fetching daily devotional: $e');
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
