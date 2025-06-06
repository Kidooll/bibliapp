// profile_screen.dart
import 'package:flutter/material.dart';
import '/services/xp_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userStats = {};
  List<Map<String, dynamic>> achievements = [];
  List<Map<String, dynamic>> xpHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => isLoading = true);

    try {
      // Carregar todas as informações do usuário
      final stats = await XPService.getUserStats();
      final userAchievements = await XPService.getUserAchievements();
      final history = await XPService.getXPHistory(limit: 10);

      setState(() {
        userStats = stats;
        achievements = userAchievements;
        xpHistory = history;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header com informações principais
                      _buildProfileHeader(),
                      const SizedBox(height: 20),

                      // Progresso de XP
                      _buildXPProgress(),
                      const SizedBox(height: 20),

                      // Streak
                      _buildStreakInfo(),
                      const SizedBox(height: 20),

                      // Conquistas recentes
                      _buildRecentAchievements(),
                      const SizedBox(height: 20),

                      // Progresso semanal
                      _buildWeeklyProgress(),
                      const SizedBox(height: 20),

                      // Histórico de XP
                      _buildXPHistory(),
                      const SizedBox(height: 20),

                      // Estatísticas gerais
                      _buildGeneralStats(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    final profile = userStats['profile'] ?? {};
    final currentLevel = profile['current_level'] ?? 1;
    final totalXP = profile['total_xp'] ?? 0;
    final coins = profile['coins'] ?? 0;
    final levelName = userStats['level_name'] ?? 'Buscador';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar e nível
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nível $currentLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      levelName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Estatísticas rápidas
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('XP Total', totalXP.toString(), Icons.star),
              _buildStatCard('Moedas', coins.toString(), Icons.monetization_on),
              _buildStatCard(
                  'Conquistas',
                  userStats['total_achievements'].toString(),
                  Icons.emoji_events),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPProgress() {
    final profile = userStats['profile'] ?? {};
    final currentLevel = profile['current_level'] ?? 1;
    final totalXP = profile['total_xp'] ?? 0;
    final xpToNext = userStats['xp_to_next_level'] ?? 100;
    final levelName = userStats['level_name'] ?? 'Buscador';

    // XP atual no nível (não total)
    final currentLevelXP = (XPService.calculateXPForLevel(currentLevel) - xpToNext).toInt();
    final totalLevelXP = XPService.calculateXPForLevel(currentLevel).toInt();

    return XPProgressWidget(
      currentXP: currentLevelXP,
      totalXP: totalLevelXP,
      currentLevel: currentLevel,
      levelName: levelName,
      primaryColor: Colors.blue[600],
    );
  }

  Widget _buildStreakInfo() {
    final profile = userStats['profile'] ?? {};
    final currentStreak = profile['current_streak'] ?? 0;
    final longestStreak = profile['longest_streak'] ?? 0;

    return StreakWidget(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }

  Widget _buildRecentAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conquistas Recentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        achievements.isEmpty
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhuma conquista ainda',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Continue lendo para desbloquear!',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final achievementData = achievement['achievements'];

                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getRarityColors(
                              achievementData['rarity'] ?? 'common'),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getAchievementIcon(
                                    achievementData['icon'] ?? 'star'),
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  achievementData['name'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            achievementData['description'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            '+${achievementData['xp_reward'] ?? 0} XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    final weeklyProgress = userStats['weekly_progress'] ?? {};
    final devotionalsRead = weeklyProgress['devotionals_read'] ?? 0;
    final goalDevotionals = weeklyProgress['goal_devotionals'] ?? 7;
    final xpEarned = weeklyProgress['xp_earned'] ?? 0;
    final progress =
        goalDevotionals > 0 ? devotionalsRead / goalDevotionals : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso Semanal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Devocionais: $devotionalsRead / $goalDevotionals',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'XP ganho esta semana: $xpEarned',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico Recente',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: xpHistory.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Nenhuma atividade recente',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: xpHistory.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final transaction = xpHistory[index];
                    final source = transaction['source'] ?? '';
                    final xpAmount = transaction['xp_amount'] ?? 0;
                    final createdAt =
                        DateTime.tryParse(transaction['created_at'] ?? '');

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Icon(
                          _getSourceIcon(source),
                          color: Colors.blue[600],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _getSourceDescription(source),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: createdAt != null
                          ? Text(
                              _formatDate(createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            )
                          : null,
                      trailing: Text(
                        '+$xpAmount XP',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGeneralStats() {
    final achievementsByRarity = userStats['achievements_by_rarity'] ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conquistas por Raridade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRarityCard(
                  'Comum', achievementsByRarity['common'] ?? 0, Colors.grey),
              _buildRarityCard(
                  'Rara', achievementsByRarity['rare'] ?? 0, Colors.blue),
              _buildRarityCard(
                  'Épica', achievementsByRarity['epic'] ?? 0, Colors.purple),
              _buildRarityCard('Lendária',
                  achievementsByRarity['legendary'] ?? 0, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRarityCard(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Métodos auxiliares
  List<Color> _getRarityColors(String rarity) {
    switch (rarity.toLowerCase()) {
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

  IconData _getAchievementIcon(String iconName) {
    switch (iconName.toLowerCase()) {
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

  IconData _getSourceIcon(String source) {
    switch (source) {
      case 'devotional_read':
        return Icons.book;
      case 'citation_read':
        return Icons.format_quote;
      case 'verse_read':
        return Icons.menu_book;
      case 'daily_goal_complete':
        return Icons.check_circle;
      case 'weekly_goal_complete':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  String _getSourceDescription(String source) {
    switch (source) {
      case 'devotional_read':
        return 'Devocional lido';
      case 'citation_read':
        return 'Citação visualizada';
      case 'verse_read':
        return 'Versículo lido';
      case 'daily_goal_complete':
        return 'Meta diária completada';
      case 'weekly_goal_complete':
        return 'Meta semanal completada';
      default:
        return 'Atividade realizada';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
