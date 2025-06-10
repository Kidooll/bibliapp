import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class UserProgressService extends ChangeNotifier {
  final _client = Supabase.instance.client;
  static const _weeklyGoal = 7; // Meta semanal padrão

  // Helper function to safely convert dynamic to int
  static int _safeToInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;

    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return defaultValue;

      // Try parsing as double first to handle cases like '1.0'
      final doubleValue = double.tryParse(trimmed);
      if (doubleValue != null) return doubleValue.toInt();

      // Try parsing as int
      final intValue = int.tryParse(trimmed);
      if (intValue != null) return intValue;
    }

    return defaultValue;
  }

  // Cache para o progresso do usuário
  Map<String, dynamic>? _cachedProgress;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  // Atualiza o progresso do usuário quando um devocional é lido
  Future<void> updateDevotionalRead(int devotionalId) async {
    final userProfileId = _client.auth.currentUser?.id;
    if (userProfileId == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // 1. Verifica se o devocional já foi lido hoje
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final existingRead = await _client
          .from('read_devotionals')
          .select()
          .eq('user_profile_id', userProfileId)
          .eq('devotional_id', devotionalId)
          .gte('read_at', startOfDay.toIso8601String())
          .lt('read_at', endOfDay.toIso8601String())
          .maybeSingle();

      if (existingRead != null) {
        print('Devocional já foi lido hoje');
        return; // Não faz nada se já leu hoje
      }

      // 2. Verifica se já leu este devocional em qualquer dia
      final anyExistingRead = await _client
          .from('read_devotionals')
          .select()
          .eq('user_profile_id', userProfileId)
          .eq('devotional_id', devotionalId)
          .maybeSingle();

      if (anyExistingRead != null) {
        print('Devocional já foi lido anteriormente');
        return; // Não faz nada se já leu antes
      }

      // 3. Se não leu, insere novo registro
      await _client.from('read_devotionals').insert({
        'user_profile_id': userProfileId,
        'devotional_id': devotionalId,
        'read_at': DateTime.now().toIso8601String(),
      });

      // 4. Atualiza o perfil do usuário
      await _updateUserProfile(userProfileId, devotionalId);

      // 5. Atualiza a sequência de leitura
      await _updateReadingStreak(userProfileId);

      // 6. Limpa o cache e notifica
      _clearCache();
      notifyListeners();
    } catch (e) {
      print('Erro ao atualizar leitura do devocional: $e');
      throw Exception('Erro ao atualizar leitura do devocional: $e');
    }
  }

  // Método de fallback caso a função RPC não esteja disponível
  Future<void> _fallbackUpdateDevotionalRead(
      String userProfileId, int devotionalId) async {
    // Verifica se já leu este devocional
    final existing = await _client
        .from('read_devotionals')
        .select()
        .eq('user_profile_id', userProfileId)
        .eq('devotional_id', devotionalId);

    if (existing.isEmpty) {
      // Adiciona à lista de lidos
      await _client.from('read_devotionals').insert({
        'user_profile_id': userProfileId,
        'devotional_id': devotionalId,
        'read_at': DateTime.now().toIso8601String(),
      });

      // Atualiza o perfil do usuário
      await _updateUserProfile(userProfileId, devotionalId);
    }
  }

  // Obtém o progresso do usuário
  Future<Map<String, dynamic>> getUserProgress() async {
    final user = _client.auth.currentUser;
    if (user == null) return _getDefaultProgress();

    // Verifica se o cache ainda é válido
    if (_cachedProgress != null && _lastFetchTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheDuration) {
        return _cachedProgress!;
      }
    }

    try {
      // 1. Obtém o perfil completo do usuário para username e outros campos
      final userProfileResponse = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      String username = 'Usuário';
      if (userProfileResponse != null) {
        username = userProfileResponse['username'] as String? ?? 'Usuário';
      }

      // 2. Obtém os dados de leitura e streaks
      final readingStatsResponse = await _client
          .rpc('get_reading_stats', params: {'p_user_profile_id': user.id});

      Map<String, dynamic> progressData = {};
      if (readingStatsResponse is List && readingStatsResponse.isNotEmpty) {
        progressData = Map<String, dynamic>.from(readingStatsResponse.first);
      } else {
        await _createInitialProfile(user.id);
        progressData = _getDefaultProgress();
      }

      // Combina os dados
      final combinedProgress = {
        'username': username,
        'total_devotionals_read':
            _safeToInt(progressData['total_devotionals_read']),
        'current_streak_days': _safeToInt(progressData['current_streak_days']),
        'longest_streak_days': _safeToInt(progressData['longest_streak_days']),
        'weekly_goal':
            _safeToInt(progressData['weekly_goal'], defaultValue: _weeklyGoal),
        'weekly_progress': _safeToInt(progressData['weekly_progress']),
        'devotionals_read': progressData['devotionals_read'] ?? [],
      };

      _cachedProgress = combinedProgress;
      _lastFetchTime = DateTime.now();

      return _cachedProgress!;
    } catch (e) {
      print('Erro ao buscar progresso: $e');
      return _getDefaultProgress();
    }
  }

  // Método para criar perfil inicial do usuário
  Future<void> _createInitialProfile(String userProfileId) async {
    try {
      await _client.from('user_profiles').insert({
        'id': userProfileId,
        'total_devotionals_read': 0,
        'current_streak_days': 0,
        'longest_streak_days': 0,
        'weekly_goal': _weeklyGoal,
        'last_active_date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erro ao criar perfil inicial: $e');
      // Se já existir, não faz nada
      if (!e.toString().contains('duplicate key') &&
          !e.toString().contains('23505')) {
        rethrow;
      }
    }
  }

  // Método de fallback para obter o progresso do usuário
  Future<Map<String, dynamic>> _fallbackGetUserProgress(
      String userProfileId) async {
    try {
      // Obtém o perfil do usuário
      final profileResponse = await _client
          .from('user_profiles')
          .select()
          .eq('id', userProfileId)
          .single();

      final profile = profileResponse;

      // Conta os devocionais lidos na semana atual
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      // Obtém os devocionais lidos na semana atual
      final response = await _client
          .from('read_devotionals')
          .select()
          .eq('user_profile_id', userProfileId)
          .gte('read_at', weekAgo.toIso8601String());

      // Obtém a sequência atual
      final currentStreak = await _getCurrentStreak(userProfileId);

      // Calcula o progresso semanal
      int weeklyProgress = 0;

      // Processa a resposta do Supabase
      if (response is List) {
        weeklyProgress = response.length;
      } else if (response is Map) {
        final data = (response as Map<String, dynamic>)['data'];
        if (data is List) {
          weeklyProgress = data.length;
        } else if (data is Map) {
          // Verifica se é um PostgrestMap
          final records = data['data'];
          if (records is List) {
            weeklyProgress = records.length;
          }
        }
      }

      // Ensure all values are properly converted to int
      final progress = {
        'total_devotionals_read': _safeToInt(profile['total_devotionals_read']),
        'current_streak_days': _safeToInt(currentStreak),
        'longest_streak_days': _safeToInt(profile['longest_streak_days']),
        'weekly_goal':
            _safeToInt(profile['weekly_goal'], defaultValue: _weeklyGoal),
        'weekly_progress': weeklyProgress,
      };

      _cachedProgress = progress;
      _lastFetchTime = DateTime.now();

      return progress;
    } catch (e) {
      print('Erro no fallbackGetUserProgress: $e');
      return _getDefaultProgress();
    }
  }

  // Atualiza o perfil do usuário após ler um devocional
  Future<void> _updateUserProfile(
      String userProfileId, int devotionalId) async {
    try {
      // 1. Verifica se o devocional já foi lido
      final existingRead = await _client
          .from('read_devotionals')
          .select()
          .eq('user_profile_id', userProfileId)
          .eq('devotional_id', devotionalId)
          .maybeSingle();

      // Se o devocional já foi lido, não incrementa o contador
      if (existingRead != null) {
        print(
            'Devocional já foi lido anteriormente, não incrementando contador');
        return;
      }

      // 2. Atualiza o total de devocionais lidos
      final profile = await _client
          .from('user_profiles')
          .select('total_devotionals_read')
          .eq('id', userProfileId)
          .single();

      final currentTotal = _safeToInt(profile['total_devotionals_read']);
      await _client.from('user_profiles').update(
          {'total_devotionals_read': currentTotal + 1}).eq('id', userProfileId);

      // 3. Atualiza o progresso semanal
      final now = DateTime.now();
      // Calcula o início da semana (segunda-feira)
      final int daysToSubtract = now.weekday == 7 ? 6 : now.weekday - 1;
      final startOfWeek = now.subtract(Duration(days: daysToSubtract));
      final startOfWeekStr =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
              .toIso8601String()
              .split('T')[0];

      final weeklyProgress = await _client
          .from('weekly_progress')
          .select('devotionals_read_this_week')
          .eq('user_profile_id', userProfileId)
          .eq('week_start_date', startOfWeekStr)
          .maybeSingle();

      if (weeklyProgress != null) {
        final currentWeeklyCount =
            _safeToInt(weeklyProgress['devotionals_read_this_week']);
        await _client
            .from('weekly_progress')
            .update({
              'devotionals_read_this_week': currentWeeklyCount + 1,
              'updated_at': DateTime.now().toIso8601String()
            })
            .eq('user_profile_id', userProfileId)
            .eq('week_start_date', startOfWeekStr);
        print('Progresso semanal atualizado para: ${currentWeeklyCount + 1}');
      } else {
        await _client.from('weekly_progress').insert({
          'user_profile_id': userProfileId,
          'week_start_date': startOfWeekStr,
          'devotionals_read_this_week': 1,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String()
        });
        print('Novo progresso semanal criado');
      }
    } catch (e) {
      print('Erro ao atualizar perfil do usuário: $e');
      throw Exception('Erro ao atualizar perfil do usuário: $e');
    }
  }

  // Atualiza a sequência de leitura
  Future<void> _updateReadingStreak(String userProfileId) async {
    try {
      // 1. Obtém a data da última leitura
      final lastReadResponse = await _client
          .from('read_devotionals')
          .select('read_at')
          .eq('user_profile_id', userProfileId)
          .order('read_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastReadResponse == null) return;

      final lastReadDate = DateTime.parse(lastReadResponse['read_at']);
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // 2. Verifica se a última leitura foi hoje ou ontem
      final isConsecutive = lastReadDate.year == today.year &&
              lastReadDate.month == today.month &&
              lastReadDate.day == today.day ||
          lastReadDate.year == yesterday.year &&
              lastReadDate.month == yesterday.month &&
              lastReadDate.day == yesterday.day;

      if (!isConsecutive) {
        // Se não for consecutivo, reseta a sequência atual
        await _client
            .from('user_profiles')
            .update({'current_streak_days': 0}).eq('id', userProfileId);
        return;
      }

      // 3. Atualiza a sequência atual
      final currentStreak = await _getCurrentStreak(userProfileId);
      final newStreak = currentStreak + 1;

      // 4. Atualiza o perfil com a nova sequência
      await _client.from('user_profiles').update({
        'current_streak_days': newStreak,
        'longest_streak_days':
            newStreak > currentStreak ? newStreak : currentStreak,
      }).eq('id', userProfileId);
    } catch (e) {
      print('Erro ao atualizar sequência de leitura: $e');
    }
  }

  // Obtém a sequência atual de leitura
  Future<int> _getCurrentStreak(String userProfileId) async {
    if (userProfileId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      final response = await _client
          .from('reading_streaks')
          .select('current_streak_days')
          .eq('user_profile_id', userProfileId)
          .order('last_active_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 0;

      final streakDays = response['current_streak_days'];
      if (streakDays is int) {
        return streakDays;
      } else if (streakDays is String) {
        return int.tryParse(streakDays) ?? 0;
      } else if (streakDays is num) {
        return streakDays.toInt();
      } else {
        return 0;
      }
    } catch (e) {
      print('Erro ao obter sequência atual: $e');
      return 0;
    }
  }

  // Obtém a maior sequência de leitura
  Future<int> _getLongestStreak(String userProfileId) async {
    if (userProfileId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      final response = await _client
          .from('reading_streaks')
          .select('longest_streak_days')
          .eq('user_profile_id', userProfileId)
          .order('longest_streak_days', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return 0;

      final streakDays = response['longest_streak_days'];
      if (streakDays is int) {
        return streakDays;
      } else if (streakDays is String) {
        return int.tryParse(streakDays) ?? 0;
      } else if (streakDays is num) {
        return streakDays.toInt();
      } else {
        return 0;
      }
    } catch (e) {
      print('Erro ao obter maior sequência: $e');
      return 0;
    }
  }

  // Retorna um progresso padrão em caso de erro
  Map<String, dynamic> _getDefaultProgress() {
    return {
      'total_devotionals_read': 0,
      'current_streak_days': 0,
      'longest_streak_days': 0,
      'weekly_goal': _weeklyGoal,
      'weekly_progress': 0,
      'username': 'Visitante',
    };
  }

  // Atualiza a meta semanal do usuário
  Future<void> updateWeeklyGoal(int newGoal) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    if (newGoal < 1 || newGoal > 7) {
      throw ArgumentError('A meta semanal deve estar entre 1 e 7 dias');
    }

    try {
      await _client.from('user_profiles').update({
        'weekly_goal': newGoal,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', user.id);

      // Atualiza o cache
      if (_cachedProgress != null) {
        _cachedProgress!['weekly_goal'] = newGoal;
      }
    } catch (e) {
      print('Erro ao atualizar meta semanal: $e');
      rethrow;
    }
  }

  // Obtém o histórico de leitura do usuário
  Future<List<DateTime>> getReadingHistory(
      {int limit = 1000, int? maxPages}) async {
    final user = _client.auth.currentUser;
    if (user == null || user.id.isEmpty) return [];

    final Set<DateTime> uniqueDates = {};
    int currentPage = 0;
    bool hasMore = true;

    while (hasMore && (maxPages == null || currentPage < maxPages)) {
      currentPage++;

      try {
        final response = await _client
            .from('read_devotionals')
            .select('read_at')
            .eq('user_id', user.id)
            .order('read_at', ascending: false)
            .range(
              currentPage * limit,
              (currentPage + 1) * limit - 1,
            );

        if (response is List) {
          for (final item in response) {
            _processDateItem(item, uniqueDates.toList());
          }
        } else if (response is Map) {
          final data = (response as Map<String, dynamic>)['data'];
          if (data is List) {
            for (final item in data) {
              _processDateItem(item, uniqueDates.toList());
            }
          }
        }

        if (response is List && response.length < limit) {
          hasMore = false;
        }
      } catch (e) {
        print('Erro ao obter histórico de leitura (página $currentPage): $e');
        hasMore = false;
      }
    }

    return uniqueDates.toList()..sort((a, b) => b.compareTo(a));
  }

  // Helper method to process a single date item
  void _processDateItem(dynamic item, List<DateTime> dates) {
    try {
      if (item is! Map) return;

      final readAt = item['read_at'];
      if (readAt == null) return;

      DateTime? date;

      if (readAt is DateTime) {
        date = readAt;
      } else if (readAt is String) {
        // Try parsing ISO 8601 format first
        date = DateTime.tryParse(readAt)?.toLocal();

        // If that fails, try other common formats
        if (date == null) {
          // Try parsing as milliseconds since epoch
          final milliseconds = int.tryParse(readAt);
          if (milliseconds != null) {
            date = DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal();
          }
        }
      } else if (readAt is num) {
        // Handle timestamp in seconds or milliseconds
        final length = readAt.toString().length;
        if (length == 10) {
          // seconds
          date = DateTime.fromMillisecondsSinceEpoch((readAt as int) * 1000)
              .toLocal();
        } else if (length == 13) {
          // milliseconds
          date = DateTime.fromMillisecondsSinceEpoch(readAt as int).toLocal();
        }
      }

      if (date != null) {
        dates.add(date);
      } else {
        print('Formato de data não suportado: $readAt');
      }
    } catch (e) {
      print('Erro ao processar data: $e');
    }
  }

  // Limpa o cache
  void _clearCache() {
    _cachedProgress = null;
    _lastFetchTime = null;
  }

  // Insere a leitura diretamente na tabela
  Future<void> _insertDevotionalReadDirectly(
      String userProfileId, String devotionalId) async {
    await _client.from('read_devotionals').insert({
      'user_profile_id': userProfileId,
      'devotional_id': devotionalId,
      'read_at': DateTime.now().toIso8601String(),
    });
  }

  // Verifica se o cache é válido
  bool _isCacheValid() {
    return _cachedProgress != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }
}
