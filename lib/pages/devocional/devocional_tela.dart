// devocional_tela.dart
import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import '../../services/local_storage_service.dart';

class DevocionalTela extends StatefulWidget {
  final Map<String, dynamic> devocional;

  const DevocionalTela({super.key, required this.devocional});

  @override
  State<DevocionalTela> createState() => _DevocionalTelaState();
}

class _DevocionalTelaState extends State<DevocionalTela> {
  double _fontSize = 17.0;
  final double _minFontSize = 12.0;
  final double _maxFontSize = 24.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    try {
      final savedSize = await LocalStorageService.loadTextSize();
      if (mounted) {
        setState(() {
          _fontSize = savedSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateFontSize(double newSize) {
    final clampedSize = newSize.clamp(_minFontSize, _maxFontSize);
    setState(() {
      _fontSize = clampedSize;
    });
    LocalStorageService.saveTextSize(clampedSize);
  }

  void _showTextSizeModal(BuildContext context) async {
    double tempSize = _fontSize;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tamanho do Texto',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('A', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Slider(
                        value: tempSize,
                        min: 14,
                        max: 28,
                        divisions: 7,
                        label: tempSize.round().toString(),
                        onChanged: (value) {
                          setModalState(() => tempSize = value);
                          setState(() => _fontSize = value);
                          LocalStorageService.saveTextSize(value);
                        },
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 28)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content, BuildContext context,
      {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Icon(icon, color: const Color(0xFF29535a), size: 20),
            if (icon != null) const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: _fontSize,
                    color: const Color(0xFF29535a),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: _fontSize,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildScripture(String verse, String reference, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF64a4a4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            verse,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFFFFFFD),
                ),
          ),
          const SizedBox(height: 6),
          Text(reference,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 12,
                    color: const Color(0xFFFFFFFD),
                  )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFfffffd),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Devocional Diário"),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              color: const Color(0xFF29535a),
              fontWeight: FontWeight.w700,
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () => _showTextSizeModal(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Devocional de hoje",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: _fontSize,
                    color: const Color(0xFF29535a),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.devocional['title'] ?? 'Sem título',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: _fontSize,
                    color: const Color(0xFF29535a),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            // Versículos
            _buildScripture(
              widget.devocional['scripture'] ?? 'Sem versículo',
              widget.devocional['reference'] ?? 'Sem referência',
              context,
            ),

            const SizedBox(height: 24),

            // Devocional
            _buildSection(
              'Devocional',
              widget.devocional['reflection'] ?? 'Sem devocional',
              context,
              icon: Icons.lightbulb_outline,
            ),

            // Aplicação
            _buildSection(
              'Como colocar em prática',
              widget.devocional['application'] ?? 'Sem aplicação',
              context,
              icon: Icons.checklist,
            ),

            // Oração
            _buildSection(
              'Oração',
              widget.devocional['prayer'] ?? 'Sem oração',
              context,
              icon: Icons.self_improvement,
            ),

            // Botões
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {/* Compartilhar */},
                    icon: const Icon(
                      Icons.share,
                      color: Color(0xFFfffffd),
                    ),
                    label: const Text(
                      'Compartilhar',
                      style: TextStyle(
                        color: Color(0xFFfffffd),
                      ),
                    ),
                    style: AppStyles.elevatedButtonStyle.copyWith(
                      backgroundColor:
                          MaterialStateProperty.all(const Color(0xFF29535a)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {/* Favoritar */},
                    icon: const Icon(
                      Icons.bookmark_border,
                      color: const Color(0xFF29535a),
                    ),
                    label: const Text('Salvar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF29535a),
                      side: BorderSide(color: const Color(0xFF29535a)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
