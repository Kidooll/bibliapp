// estudo_detalhes_page.dart
import 'package:flutter/material.dart';
import '../styles/styles.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../services/study_service.dart';

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
class EstudoDetalhesPage extends StatefulWidget {
  final Map<String, dynamic> estudo;

  const EstudoDetalhesPage({super.key, required this.estudo});

  @override
  State<EstudoDetalhesPage> createState() => _EstudoDetalhesPageState();
}

class _EstudoDetalhesPageState extends State<EstudoDetalhesPage> {
  bool _isFavorito = false;
  bool _isLido = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarStatus();
  }

  Future<void> _carregarStatus() async {
    final studyService = Provider.of<StudyService>(context, listen: false);
    final String studyId = widget.estudo['id'] ?? '';
    
    if (studyId.isNotEmpty) {
      final isFav = await studyService.isEstudoFavoritado(studyId);
      final isRead = await studyService.isEstudoLido(studyId);
      
      if (mounted) {
        setState(() {
          _isFavorito = isFav;
          _isLido = isRead;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studyService = Provider.of<StudyService>(context);
    final String studyId = widget.estudo['id'] ?? '';
    final tags = widget.estudo['tags'];
    final metadata = widget.estudo['metadata'];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estudo['title'] ?? 'Sem título'),
        actions: [
          // Botão de favoritar
          _isLoading
              ? const SizedBox(width: 48, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
              : IconButton(
                  icon: Icon(
                    _isFavorito ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorito ? Colors.red : null,
                  ),
                  onPressed: () {
                    if (studyId.isEmpty) return;
                    
                    setState(() => _isFavorito = !_isFavorito);
                    
                    if (_isFavorito) {
                      studyService.favoritarEstudo(studyId);
                    } else {
                      studyService.desfavoritarEstudo(studyId);
                    }
                  },
                ),
          // Botão de marcar como lido
          _isLoading
              ? const SizedBox(width: 48, child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
              : IconButton(
                  icon: Icon(
                    _isLido ? Icons.check_circle : Icons.check_circle_outline,
                    color: _isLido ? AppStyles.primaryGreen : null,
                  ),
                  onPressed: () {
                    if (studyId.isEmpty) return;
                    
                    setState(() => _isLido = true);
                    studyService.marcarEstudoComoLido(studyId);
                  },
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppStyles.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags do estudo (se existirem)
            if (tags != null && tags is List && tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    tags.length,
                    (index) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tags[index].toString(),
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                      ),
                    ),
                  ),
                ),
              ),
            
            // Conteúdo do estudo
            if (widget.estudo['content'] != null &&
                widget.estudo['content'].toString().isNotEmpty)
              Html(
                data: _formatarTexto(widget.estudo['content']),
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
