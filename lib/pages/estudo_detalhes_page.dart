// estudo_detalhes_page.dart
import 'package:flutter/material.dart';
import '../styles/styles.dart';
import 'package:flutter_html/flutter_html.dart';

// estudo_detalhes_page.dart
String _formatarTexto(String texto) {
  // Substitui quebras de linha por <br>
  String formatted = texto.replaceAll('\n', '<br>');

  // Adiciona parágrafos (opcional)
  formatted = "<p>$formatted</p>";

  // Destaque palavras entre ** (ex: **importante** → <strong>importante</strong>)
  formatted = formatted.replaceAllMapped(
    RegExp(r'\*\*(.*?)\*\*'),
    (match) => '<strong>${match.group(1)}</strong>',
  );

  return formatted;
}

// estudo_detalhes_page.dart
class EstudoDetalhesPage extends StatelessWidget {
  final Map<String, dynamic> estudo;

  const EstudoDetalhesPage({super.key, required this.estudo});

  @override
  Widget build(BuildContext context) {
    print('Dados recebidos na página de detalhes: $estudo'); // Debug

    return Scaffold(
      appBar: AppBar(
        title: Text(estudo['title'] ?? 'Sem título'),
      ),
      body: SingleChildScrollView(
        padding: AppStyles.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (estudo['content'] != null &&
                estudo['content'].toString().isNotEmpty)
              Html(
                data: _formatarTexto(estudo['content']),
                style: {
                  "p": Style(
                    fontSize: FontSize(16.0),
                    margin: Margins.only(bottom: 12),
                  ),
                  "strong": Style(
                    color: AppStyles.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                },
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Nenhum conteúdo disponível'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
