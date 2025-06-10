import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../services/user_progress_service.dart';
import '../models/devotional.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  late CalendarFormat _calendarFormat;

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
    _calendarFormat = CalendarFormat.month;
    initializeDateFormatting('pt_BR', null);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final progress = await widget.progressService.getUserProgress();
      final readDevotionals =
          progress['devotionals_read'] as List<dynamic>? ?? [];

      setState(() {
        _events = {};
        for (var devotional in readDevotionals) {
          try {
            final date = DateTime.parse(devotional['read_at']).toLocal();
            final dateKey = DateTime(date.year, date.month, date.day);

            if (!_events.containsKey(dateKey)) {
              _events[dateKey] = [];
            }
            _events[dateKey]!.add(Devotional.fromJson(devotional));
          } catch (e) {
            print('Erro ao processar devocional: $e');
          }
        }
      });
    } catch (e) {
      print('Erro ao carregar eventos: $e');
    }
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
      calendarFormat: _calendarFormat,
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.monday,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
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
        markerSize: 8,
        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(
          color: Color(0xFF5E9EA0),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        formatButtonTextStyle: TextStyle(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Color(0xFF5E9EA0),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          if (day.weekday == DateTime.sunday) {
            return Center(
              child: Text(
                'Dom',
                style: TextStyle(color: Colors.red[300]),
              ),
            );
          }
          if (day.weekday == DateTime.saturday) {
            return const Center(
              child: Text(
                'Sáb',
                style: TextStyle(color: Colors.blue),
              ),
            );
          }
          return null;
        },
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;
          return Positioned(
            bottom: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: events.map((event) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            ),
          );
        },
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
      locale: 'pt_BR',
    );
  }

  Widget _buildAnimatedStreak() {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.progressService.getUserProgress(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final currentStreak = snapshot.data!['current_streak_days'] ?? 0;
        final longestStreak = snapshot.data!['longest_streak_days'] ?? 0;
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
              '$currentStreak dias seguidos!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Recorde: $longestStreak dias',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor.withOpacity(0.8),
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
