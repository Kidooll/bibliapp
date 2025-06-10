import 'package:flutter/material.dart';
import '../../pages/devocional/devocional_tela.dart';
import '../../pages/devocional/citacao_tela.dart';

class CombinedCardWidget extends StatelessWidget {
  final Map<String, dynamic> devotional;
  final String? imageUrl;

  const CombinedCardWidget({
    super.key,
    required this.devotional,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5E9EA0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuoteSection(context),
          const SizedBox(height: 8),
          Text(
            devotional['citation'] ??
                'A vida é um eco. O que você envia volta para você.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          _buildDevotionalSection(context),
          const SizedBox(height: 8),
          Text(
            devotional['title'] ?? 'Renovação a Cada Dia',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          _buildVerseSection(),
        ],
      ),
    );
  }

  Widget _buildQuoteSection(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Citação do Dia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: imageUrl == null
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CitacaoTela(
                        imagemUrl: imageUrl!,
                        citacao: devotional['citation'] ??
                            'A vida é um eco. O que você envia volta para você.',
                        autor: devotional['author'] ?? 'Autor Desconhecido',
                      ),
                    ),
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: const Text(
            'Ler',
            style: TextStyle(
              color: Color(0xFF5E9EA0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevotionalSection(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Devocional de hoje',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DevocionalTela(devocional: devotional),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: const Text(
            'Ler',
            style: TextStyle(
              color: Color(0xFF5E9EA0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Versículo do Dia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          devotional['verso'] ??
              'O Senhor é bom para que esperam nele, para a alma que o busca.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          devotional['verso2'] ?? 'Lamentações 3:25',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.white.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}
