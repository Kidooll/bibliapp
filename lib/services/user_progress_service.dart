import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class UserProgressService {
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
  Future<void> updateDevotionalRead(String devotionalId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      // Insere o registro de leitura - o trigger cuidará do resto
      await _client.from('read_devotionals').insert({
        'user_id': user.id,
        'devotional_id': devotionalId,
        'read_at': DateTime.now().toIso8601String(),
      });

      // Limpa o cache após atualização
      _clearCache();
    } catch (e) {
      print('Erro ao atualizar progresso: $e');
      // Se já existir um registro, não faz nada (idempotência)
      if (!e.toString().contains('duplicate key') &&
          !e.toString().contains('23505')) {
        rethrow;
      }
    }
  }

  // Método de fallback caso a função RPC não esteja disponível
  Future<void> _fallbackUpdateDevotionalRead(
      String userId, String devotionalId) async {
    // Verifica se já leu este devocional
    final existing = await _client
        .from('read_devotionals')
        .select()
        .eq('user_id', userId)
        .eq('devotional_id', devotionalId);

    if (existing.isEmpty) {
      // Adiciona à lista de lidos
      await _client.from('read_devotionals').insert({
        'user_id': userId,
        'devotional_id': devotionalId,
        'read_at': DateTime.now().toIso8601String(),
      });

      // Atualiza o perfil do usuário
      await _updateUserProfile(userId);
    }
  }

  // Obtém o progresso do usuário
  Future<Map<String, dynamic>> getUserProgress() async {
    final user = _client.auth.currentUser;
    if (user == null) return _getDefaultProgress();

    // Retorna dados em cache se ainda forem válidos
    if (_isCacheValid()) {
      return _cachedProgress!;
    }

    try {
      // Usa a função RPC get_reading_stats
      final response = await _client
          .rpc('get_reading_stats', params: {'p_user_id': user.id});

      if (response is List && response.isNotEmpty) {
        _cachedProgress = Map<String, dynamic>.from(response.first);
      } else {
        // Se não houver dados, cria um perfil inicial
        await _createInitialProfile(user.id);
        _cachedProgress = _getDefaultProgress();
      }

      _lastFetchTime = DateTime.now();
      return _cachedProgress!;
    } catch (e) {
      print('Erro ao buscar progresso: $e');
      return _getDefaultProgress();
    }
  }

  // Método para criar perfil inicial do usuário
  Future<void> _createInitialProfile(String userId) async {
    try {
      await _client.from('user_profiles').insert({
        'user_id': userId,
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
  Future<Map<String, dynamic>> _fallbackGetUserProgress(String userId) async {
    try {
      // Obtém o perfil do usuário
      final profileResponse = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      final profile = profileResponse;

      // Conta os devocionais lidos na semana atual
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      // Obtém os devocionais lidos na semana atual
      final response = await _client
          .from('read_devotionals')
          .select()
          .eq('user_id', userId)
          .gte('read_at', weekAgo.toIso8601String());

      // Obtém a sequência atual
      final currentStreak = await _getCurrentStreak(userId);

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
        'total_devotionals_read': (profile['total_devotionals_read'] is int)
            ? profile['total_devotionals_read'] as int
            : int.tryParse(
                    profile['total_devotionals_read']?.toString() ?? '0') ??
                0,
        'current_streak_days': currentStreak is int
            ? currentStreak
            : int.tryParse(currentStreak.toString()) ?? 0,
        'longest_streak_days': (profile['longest_streak_days'] is int)
            ? profile['longest_streak_days'] as int
            : int.tryParse(profile['longest_streak_days']?.toString() ?? '0') ??
                0,
        'weekly_goal': (profile['weekly_goal'] is int)
            ? profile['weekly_goal'] as int
            : int.tryParse(profile['weekly_goal']?.toString() ??
                    _weeklyGoal.toString()) ??
                _weeklyGoal,
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

  // Obtém a sequência atual de leitura
  Future<int> _getCurrentStreak(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      final response = await _client
          .from('reading_streaks')
          .select()
          .eq('user_id', userId)
          .eq('is_current', true)
          .single();

      if (response == null) return 0;

      final streakDays = response['streak_days'];
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

  // Retorna um progresso padrão em caso de erro
  Map<String, dynamic> _getDefaultProgress() {
    return {
      'total_devotionals_read': 0,
      'current_streak_days': 0,
      'longest_streak_days': 0,
      'weekly_goal': _weeklyGoal,
      'weekly_progress': 0,
    };
  }

  // Atualiza o perfil do usuário após ler um devocional
  Future<void> _updateUserProfile(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    try {
      final now = DateTime.now().toLocal();

      // Obtém o total de devocionais lidos
      final response =
          await _client.from('read_devotionals').select().eq('user_id', userId);

      int totalRead = 0;
      if (response is List) {
        totalRead = response.length;
      }

      // Obtém a sequência atual
      final currentStreak = await _getCurrentStreak(userId);

      // Verifica se o perfil existe
      final profileResponse =
          await _client.from('user_profiles').select().eq('user_id', userId);

      final Map<String, dynamic> profileData = {
        'total_devotionals_read': totalRead,
        'current_streak_days': currentStreak,
        'last_read_at': now.toIso8601String(),
        'last_active_date': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      if (profileResponse.isEmpty) {
        // Cria novo perfil
        await _client.from('user_profiles').insert({
          ...profileData,
          'user_id': userId,
          'longest_streak_days': currentStreak,
          'created_at': now.toIso8601String(),
          'weekly_goal': _weeklyGoal,
        });
      } else {
        // Atualiza perfil existente
        final profile = profileResponse.first;
        final longestStreak = _safeToInt(profile['longest_streak_days']);

        // Atualiza o recorde se necessário
        if (currentStreak > longestStreak) {
          profileData['longest_streak_days'] = currentStreak;
        } else {
          profileData['longest_streak_days'] = longestStreak;
        }

        await _client
            .from('user_profiles')
            .update(profileData)
            .eq('user_id', userId);
      }

      // Limpa o cache após atualização
      _clearCache();
    } catch (e) {
      print('Erro ao atualizar perfil do usuário: $e');
      rethrow;
    }
  }

  // Atualiza a sequência de leitura do usuário
  Future<void> _updateReadingStreak(String userId, DateTime readDate) async {
    try {
      // Obtém a sequência atual
      final currentStreakResponse = await _client
          .from('reading_streaks')
          .select()
          .eq('user_id', userId)
          .eq('is_current', true);

      final readDateOnly =
          DateTime(readDate.year, readDate.month, readDate.day);

      if (currentStreakResponse.isEmpty) {
        // Primeira leitura - cria uma nova sequência
        await _client.from('reading_streaks').insert({
          'user_id': userId,
          'start_date': readDateOnly.toIso8601String(),
          'end_date': readDateOnly.toIso8601String(),
          'is_current': true,
          'streak_days': 1,
        });
      } else {
        final currentStreak = currentStreakResponse.first;
        final lastReadDate = DateTime.parse(currentStreak['end_date']);
        final daysSinceLastRead = readDateOnly.difference(lastReadDate).inDays;

        if (daysSinceLastRead == 0) {
          // Já leu hoje, não faz nada
          return;
        } else if (daysSinceLastRead == 1) {
          // Leitura consecutiva - atualiza a sequência atual
          await _client.from('reading_streaks').update({
            'end_date': readDateOnly.toIso8601String(),
            'streak_days': (currentStreak['streak_days'] as int) + 1,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', currentStreak['id']);

          // Atualiza o recorde se necessário
          if ((currentStreak['streak_days'] as int) + 1 >
              (currentStreak['longest_streak_days'] as int)) {
            await _client.from('user_profiles').update({
              'longest_streak_days': (currentStreak['streak_days'] as int) + 1,
              'updated_at': DateTime.now().toIso8601String(),
            }).eq('user_id', userId);
          }
        } else if (daysSinceLastRead > 1) {
          // Quebrou a sequência - marca a atual como inativa e cria uma nova
          await _client.from('reading_streaks').update({
            'is_current': false,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', currentStreak['id']);

          // Cria uma nova sequência
          await _client.from('reading_streaks').insert({
            'user_id': userId,
            'start_date': readDateOnly.toIso8601String(),
            'end_date': readDateOnly.toIso8601String(),
            'is_current': true,
            'streak_days': 1,
          });
        }
      }
    } catch (e) {
      print('Erro ao atualizar sequência de leitura: $e');
      rethrow;
    }
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
      String userId, String devotionalId) async {
    await _client.from('read_devotionals').insert({
      'user_id': userId,
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
