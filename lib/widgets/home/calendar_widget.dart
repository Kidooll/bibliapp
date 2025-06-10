import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatelessWidget {
  final List<DateTime> calendarDays;

  const CalendarWidget({
    super.key,
    required this.calendarDays,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdayFormat = DateFormat('E', 'pt_BR');
    final dayFormat = DateFormat('d');
    final monthFormat = DateFormat('MMMM', 'pt_BR');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                monthFormat.format(now).capitalize(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(calendarDays.length, (index) {
              final day = calendarDays[index];
              final isSelected = day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;

              return Container(
                width: 40,
                height: 65,
                decoration: isSelected
                    ? BoxDecoration(
                        color: const Color(0xFF5E9EA0),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekdayFormat.format(day)[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dayFormat.format(day),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
