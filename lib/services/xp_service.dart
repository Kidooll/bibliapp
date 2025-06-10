// xp_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class XPService {
  static final _supabase = Supabase.instance.client;

  // Modelos de dados
  static const Map<String, int> XP_VALUES = {
    'devotional_read': 25,
    'citation_read': 10,
    'verse_read': 5,
    'daily_goal_complete': 50,
    'weekly_goal_complete': 100,
  };

  static const Map<int, double> STREAK_MULTIPLIERS = {
    7: 1.5, // +50% após 7 dias
    14: 2.0, // +100% após 14 dias
    30: 2.5, // +150% após 30 dias
  };

  // Sistema de níveis inspiradores
  static const Map<int, String> LEVEL_NAMES = {
    1: 'Buscador',
    5: 'Discípulo',
    10: 'Guardião da Fé',
    15: 'Sábio Espiritual',
    20: 'Mensageiro Divino',
    25: 'Luz no Caminho',
    30: 'Pastor Celestial',
    35: 'Profeta da Esperança',
    40: 'Anjo da Guarda',
    50: 'Santo Iluminado',
  };

  // Buscar perfil do usuário
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }

  // Criar perfil inicial se não existir
  static Future<void> initializeUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Verificar se já existe
      final existing = await getUserProfile();
      if (existing != null) return;

      // Criar novo perfil
      await _supabase.from('user_profiles').insert({
        'id': user.id,
        'total_xp': 0,
        'current_level': 1,
        'xp_to_next_level': 100,
        'coins': 0,
        'current_streak': 0,
        'longest_streak': 0,
        'last_activity_date': DateTime.now().toIso8601String().split('T')[0],
      });

      print('Perfil de usuário criado com sucesso');
    } catch (e) {
      print('Erro ao inicializar perfil: $e');
    }
  }

  // Adicionar XP por ação
  static Future<Map<String, dynamic>?> addXP({
    required String action,
    String? referenceId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Calcular XP base
      int baseXP = XP_VALUES[action] ?? 0;
      if (baseXP == 0) return null;

      // Aplicar multiplicador de streak se aplicável
      double finalXP = baseXP.toDouble();
      if (additionalData != null &&
          additionalData.containsKey('current_streak')) {
        int streak = additionalData['current_streak'];
        double multiplier = _getStreakMultiplier(streak);
        finalXP = baseXP * multiplier;
      }

      // Chamar função do Supabase para adicionar XP
      final result = await _supabase.rpc('add_xp', params: {
        'p_user_profile_id': user.id,
        'p_xp_amount': finalXP.round(),
        'p_source': action,
        'p_reference_id': referenceId,
      });

      return result.first;
    } catch (e) {
      print('Erro ao adicionar XP: $e');
      return null;
    }
  }

  // Calcular multiplicador de streak
  static double _getStreakMultiplier(int streak) {
    for (int threshold in STREAK_MULTIPLIERS.keys.toList().reversed) {
      if (streak >= threshold) {
        return STREAK_MULTIPLIERS[threshold]!;
      }
    }
    return 1.0;
  }

  // Obter nome do nível atual
  static String getLevelName(int level) {
    String levelName = 'Buscador';
    for (int threshold in LEVEL_NAMES.keys.toList().reversed) {
      if (level >= threshold) {
        levelName = LEVEL_NAMES[threshold]!;
        break;
      }
    }
    return levelName;
  }

  // Calcular XP necessário para próximo nível
  static int calculateXPForLevel(int level) {
    return (level * 100) + (level * level * 10);
  }

  // Buscar conquistas do usuário
  static Future<List<Map<String, dynamic>>> getUserAchievements() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('user_achievements')
          .select('''
            *,
            achievements:achievement_id (
              name,
              description,
              icon,
              xp_reward,
              coin_reward,
              rarity
            )
          ''')
          .eq('user_profile_id', user.id)
          .order('earned_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar conquistas: $e');
      return [];
    }
  }

  // Buscar conquistas disponíveis (não conquistadas)
  static Future<List<Map<String, dynamic>>> getAvailableAchievements() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final achievedIds = await _getUserAchievementIds();
      String notInClause = achievedIds.isEmpty ? '' : achievedIds.join(',');

      var query = _supabase.from('achievements').select().eq('is_active', true);

      if (notInClause.isNotEmpty) {
        query = query.not('id', 'in', '($notInClause)');
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar conquistas disponíveis: $e');
      return [];
    }
  }

  // IDs das conquistas já obtidas
  static Future<List<String>> _getUserAchievementIds() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('user_achievements')
          .select('achievement_id')
          .eq('user_profile_id', user.id);

      return response
          .map<String>((item) => item['achievement_id'].toString())
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Buscar itens da loja
  static Future<List<Map<String, dynamic>>> getShopItems() async {
    try {
      final response = await _supabase
          .from('shop_items')
          .select()
          .eq('is_available', true)
          .order('cost_coins');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar itens da loja: $e');
      return [];
    }
  }

  // Comprar item da loja
  static Future<bool> purchaseItem(String itemId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Buscar item e verificar se usuário tem moedas suficientes
      final item =
          await _supabase.from('shop_items').select().eq('id', itemId).single();

      final profile = await getUserProfile();
      if (profile == null || profile['coins'] < item['cost_coins']) {
        print('Erro: Saldo insuficiente ou item não encontrado');
        return false;
      }

      // Registrar compra
      await _supabase.from('user_purchases').insert({
        'user_profile_id': user.id,
        'shop_item_id': item['id'],
        'purchased_at': DateTime.now().toIso8601String(),
        'cost_coins_at_purchase': item['cost_coins'],
        'cost_xp_at_purchase': item['cost_xp'],
      });

      // Deduzir moedas e XP
      await _supabase.rpc('deduct_coins_and_xp', params: {
        'p_user_profile_id': user.id,
        'p_coins_amount': item['cost_coins'],
        'p_xp_amount': item['cost_xp'],
      });

      print('Item comprado com sucesso!');
      return true;
    } catch (e) {
      print('Erro ao comprar item: $e');
      return false;
    }
  }

  // Buscar itens comprados do usuário
  static Future<List<Map<String, dynamic>>> getUserPurchases() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase.from('user_purchases').select('''
            *,
            shop_items:item_id (
              name,
              item_type,
              item_data
            )
          ''').eq('user_profile_id', user.id);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar compras: $e');
      return [];
    }
  }

  // Ativar item comprado (ex: tema, avatar)
  static Future<bool> activateItem(String purchaseId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Desativar outros itens do mesmo tipo
      await _supabase
          .from('user_purchases')
          .update({'is_active': false}).eq('user_profile_id', user.id);

      // Ativar o item selecionado
      await _supabase
          .from('user_purchases')
          .update({'is_active': true})
          .eq('id', purchaseId)
          .eq('user_profile_id', user.id);

      return true;
    } catch (e) {
      print('Erro ao ativar item: $e');
      return false;
    }
  }

  // Buscar progresso semanal
  static Future<Map<String, dynamic>?> getWeeklyProgress() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Calcular início da semana (segunda-feira)
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDate =
          DateTime(weekStart.year, weekStart.month, weekStart.day);

      final response = await _supabase
          .from('weekly_progress')
          .select()
          .eq('user_profile_id', user.id)
          .eq('week_start', weekStartDate.toIso8601String().split('T')[0])
          .maybeSingle();

      // Se não existe, criar
      if (response == null) {
        await _supabase.from('weekly_progress').insert({
          'user_profile_id': user.id,
          'week_start': weekStartDate.toIso8601String().split('T')[0],
          'devotionals_read': 0,
          'citations_read': 0,
          'xp_earned': 0,
          'goal_devotionals': 7,
        });

        return {
          'devotionals_read': 0,
          'citations_read': 0,
          'xp_earned': 0,
          'goal_devotionals': 7,
          'goal_completed': false,
        };
      }

      return response;
    } catch (e) {
      print('Erro ao buscar progresso semanal: $e');
      return null;
    }
  }

  // Atualizar progresso semanal
  static Future<void> updateWeeklyProgress({
    int? devotionalsRead,
    int? citationsRead,
    int? xpEarned,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDate =
          DateTime(weekStart.year, weekStart.month, weekStart.day);

      Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (devotionalsRead != null) {
        updates['devotionals_read'] = devotionalsRead;
      }
      if (citationsRead != null) {
        updates['citations_read'] = citationsRead;
      }
      if (xpEarned != null) {
        updates['xp_earned'] = xpEarned;
      }

      await _supabase.from('weekly_progress').upsert({
        'user_profile_id': user.id,
        'week_start': weekStartDate.toIso8601String().split('T')[0],
        ...updates,
      });
    } catch (e) {
      print('Erro ao atualizar progresso semanal: $e');
    }
  }

  // Buscar histórico de XP
  static Future<List<Map<String, dynamic>>> getXPHistory(
      {int limit = 50}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('xp_transactions')
          .select()
          .eq('user_profile_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar histórico de XP: $e');
      return [];
    }
  }

  // Estatísticas do usuário
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final profile = await getUserProfile();
      if (profile == null) return {};

      final achievements = await getUserAchievements();
      final weeklyProgress = await getWeeklyProgress();

      return {
        'profile': profile,
        'total_achievements': achievements.length,
        'weekly_progress': weeklyProgress,
        'achievements_by_rarity': _groupAchievementsByRarity(achievements),
        'level_name': getLevelName(profile['current_level']),
        'xp_to_next_level': calculateXPForLevel(profile['current_level'] + 1) -
            profile['total_xp'],
      };
    } catch (e) {
      print('Erro ao buscar estatísticas: $e');
      return {};
    }
  }

  // Agrupar conquistas por raridade
  static Map<String, int> _groupAchievementsByRarity(
      List<Map<String, dynamic>> achievements) {
    Map<String, int> counts = {
      'common': 0,
      'rare': 0,
      'epic': 0,
      'legendary': 0
    };

    for (var achievement in achievements) {
      String rarity = achievement['achievements']['rarity'] ?? 'common';
      counts[rarity] = (counts[rarity] ?? 0) + 1;
    }

    return counts;
  }

  // Atualizar streak diário
  static Future<Map<String, dynamic>?> updateDailyStreak() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final result = await _supabase.rpc('update_daily_streak', params: {
        'p_user_profile_id': user.id,
      });

      return result.first;
    } catch (e) {
      print('Erro ao atualizar streak: $e');
      return null;
    }
  }
}

// Modelo para notificações de conquistas
class AchievementNotification {
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final int coinReward;
  final String rarity;

  AchievementNotification({
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.coinReward,
    required this.rarity,
  });
}

// Widget para exibir notificação de conquista
class AchievementPopup extends StatelessWidget {
  final AchievementNotification achievement;
  final VoidCallback? onClose;

  const AchievementPopup({
    Key? key,
    required this.achievement,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getRarityColors(achievement.rarity),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
                  _getRarityColors(achievement.rarity).first.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone da conquista
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                _getIconFromString(achievement.icon),
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              'Conquista Desbloqueada!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Nome da conquista
            Text(
              achievement.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Descrição
            Text(
              achievement.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Recompensas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (achievement.xpReward > 0) ...[
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.xpReward} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (achievement.xpReward > 0 && achievement.coinReward > 0)
                  const SizedBox(width: 16),
                if (achievement.coinReward > 0) ...[
                  Icon(Icons.monetization_on, color: Colors.yellow, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.coinReward} moedas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Botão fechar
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _getRarityColors(achievement.rarity).first,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getRarityColors(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return [Colors.grey[600]!, Colors.grey[400]!];
      case 'rare':
        return [Colors.blue[600]!, Colors.blue[400]!];
      case 'epic':
        return [Colors.purple[600]!, Colors.purple[400]!];
      case 'legendary':
        return [Colors.orange[600]!, Colors.amber[400]!];
      default:
        return [Colors.grey[600]!, Colors.grey[400]!];
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'star':
        return Icons.star;
      case 'trophy':
        return Icons.emoji_events;
      case 'fire':
        return Icons.local_fire_department;
      case 'book':
        return Icons.book;
      case 'crown':
        return Icons.workspace_premium;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.star;
    }
  }
}

// Widget para mostrar progresso de XP
class XPProgressWidget extends StatelessWidget {
  final int currentXP;
  final int totalXP;
  final int currentLevel;
  final String levelName;
  final Color? primaryColor;

  const XPProgressWidget({
    Key? key,
    required this.currentXP,
    required this.totalXP,
    required this.currentLevel,
    required this.levelName,
    this.primaryColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = totalXP > 0 ? currentXP / totalXP : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor!.withOpacity(0.1),
            primaryColor!.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor!.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nível $currentLevel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    levelName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$currentXP / $totalXP XP',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor!),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar streak atual
class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final Color? primaryColor;

  const StreakWidget({
    Key? key,
    required this.currentStreak,
    required this.longestStreak,
    this.primaryColor = Colors.orange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.red.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sequência Atual',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$currentStreak dias',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Recorde',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$longestStreak dias',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
