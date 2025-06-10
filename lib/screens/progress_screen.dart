import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_progress_service.dart';
import '../widgets/interactive_calendar.dart';
import '../models/devotional.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Progresso'),
      ),
      body: Consumer<UserProgressService>(
        builder: (context, progressService, child) {
          return FutureBuilder<Map<String, dynamic>>(
            future: progressService.getUserProgress(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar progresso: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final progress = snapshot.data!;
              final weeklyProgress =
                  progress['weekly_progress'] as Map<String, dynamic>;
              final totalRead = progress['total_devotionals_read'] ?? 0;
              final currentStreak = progress['current_streak'] ?? 0;
              final maxStreak = progress['max_streak'] ?? 0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InteractiveCalendar(
                      progressService: progressService,
                      onDaySelected: (date) {
                        // Aqui você pode implementar a navegação para os devocionais do dia
                        print('Dia selecionado: $date');
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildProgressCard(
                      context,
                      'Esta Semana',
                      '${weeklyProgress['devotionals_read_this_week'] ?? 0} devocionais lidos',
                      weeklyProgress['devotionals_read_this_week'] ?? 0,
                      7,
                    ),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                      context,
                      'Total Lido',
                      '$totalRead devocionais',
                      totalRead,
                      100,
                    ),
                    const SizedBox(height: 16),
                    _buildStreakCard(
                      context,
                      currentStreak,
                      maxStreak,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    String title,
    String subtitle,
    int value,
    int maxValue,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: value / maxValue,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(
    BuildContext context,
    int currentStreak,
    int maxStreak,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sequência de Leitura',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$currentStreak dias seguidos',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (maxStreak > currentStreak) ...[
              const SizedBox(height: 8),
              Text(
                'Seu recorde: $maxStreak dias',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
