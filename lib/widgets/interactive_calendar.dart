import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../services/user_progress_service.dart';
import '../models/devotional.dart';

class InteractiveCalendar extends StatefulWidget {
  final UserProgressService progressService;
  final Function(DateTime) onDaySelected;

  const InteractiveCalendar({
    Key? key,
    required this.progressService,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  State<InteractiveCalendar> createState() => _InteractiveCalendarState();
}

class _InteractiveCalendarState extends State<InteractiveCalendar>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Map<DateTime, List<Devotional>> _events;
  late AnimationController _streakController;
  late Animation<double> _streakAnimation;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _events = {};
    _streakController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _streakAnimation = CurvedAnimation(
      parent: _streakController,
      curve: Curves.easeInOut,
    );
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final progress = await widget.progressService.getUserProgress();
    final readDevotionals = progress['read_devotionals'] as List<dynamic>;

    setState(() {
      _events = {};
      for (var devotional in readDevotionals) {
        final date = DateTime.parse(devotional['read_at']).toLocal();
        final dateKey = DateTime(date.year, date.month, date.day);

        if (!_events.containsKey(dateKey)) {
          _events[dateKey] = [];
        }
        _events[dateKey]!.add(Devotional.fromJson(devotional));
      }
    });
  }

  List<Devotional> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthlyOverview(),
          const SizedBox(height: 16),
          _buildAnimatedStreak(),
          const SizedBox(height: 16),
          _buildStreakRecovery(),
        ],
      ),
    );
  }

  Widget _buildMonthlyOverview() {
    return TableCalendar(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.month,
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        markersMaxCount: 1,
        markerDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        widget.onDaySelected(selectedDay);
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildAnimatedStreak() {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.progressService.getUserProgress(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final streak = snapshot.data!['current_streak'] ?? 0;
        _streakController.forward(from: 0);

        return Column(
          children: [
            Lottie.asset(
              'assets/animations/fire.json',
              controller: _streakController,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 8),
            Text(
              '$streak dias seguidos!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStreakRecovery() {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.progressService.getUserProgress(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final streak = snapshot.data!['current_streak'] ?? 0;
        final maxStreak = snapshot.data!['max_streak'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'Seu Recorde: $maxStreak dias',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (streak < maxStreak)
                Text(
                  'Você está a ${maxStreak - streak} dias do seu recorde!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _streakController.dispose();
    super.dispose();
  }
}
