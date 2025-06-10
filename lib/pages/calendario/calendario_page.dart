import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_progress_service.dart';
import '../../widgets/interactive_calendar.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userProgressService =
        Provider.of<UserProgressService>(context, listen: false);
    await userProgressService.getUserProgress();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário de Leituras'),
        backgroundColor: const Color(0xFF5E9EA0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : InteractiveCalendar(
              progressService:
                  Provider.of<UserProgressService>(context, listen: false),
              onDaySelected: (day) {
                // Aqui você pode adicionar lógica adicional quando um dia é selecionado
              },
            ),
    );
  }
}
