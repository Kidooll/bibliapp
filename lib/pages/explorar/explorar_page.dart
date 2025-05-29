import 'package:bibliapp/styles/styles.dart';
import 'package:flutter/material.dart';
import '../../services/unsplash.dart';
import 'components/estudos_section.dart';
import 'components/para_dormir_section.dart';
import 'components/mente_section.dart';
import 'package:firebase_core/firebase_core.dart';

class ExplorarPage extends StatelessWidget {
  const ExplorarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F9),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Barra de busca
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: AppStyles.searchFieldDecoration,
              ),
            ),
            // 📄 Conteúdo rolável
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    EstudosSection(),
                    ParaDormirSection(),
                    MenteSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
