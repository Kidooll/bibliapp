import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/services/supabase_service.dart';
import '/styles/styles.dart';

// Dicionário de cores
final Map<String, Color> highlightColors = {
  'amarelo': const Color(0xFFFFF9C4),
  'azul': const Color(0xFFB2EBF2),
  'laranja': const Color(0xFFFFCCBC),
  'verde': const Color(0xFFC8E6C9),
  'roxo': const Color(0xFFE1BEE7),
};

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _notas = [];
  String? _filtroCor;
  final List<String> _cores = ['rosa', 'amarelo', 'roxo', 'azul', 'verde'];

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  Future<void> _carregarNotas() async {
    final notas = await _supabaseService.listarNotasDoUsuario();
    setState(() {
      _notas = _filtroCor == null
          ? notas
          : notas.where((n) => n['highlight_color'] == _filtroCor).toList();
    });
  }

  void _mostrarDialogoNovaNota(BuildContext context) {
    final TextEditingController _notaController = TextEditingController();
    final TextEditingController _verseController = TextEditingController();
    String _corSelecionada = highlightColors.keys.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF1FFFD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                "Nova Anotação",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppStyles.primaryGreen),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Seletor de cores
                    Wrap(
                      spacing: 12,
                      children: highlightColors.entries.map((entry) {
                        final isSelected = _corSelecionada == entry.key;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _corSelecionada = entry.key;
                            });
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppStyles.primaryGreen,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 20, color: Colors.black54)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Campo de texto da nota
                    TextField(
                      controller: _notaController,
                      decoration: InputDecoration(
                        hintText: "Digite sua anotação",
                        hintStyle:
                            const TextStyle(color: AppStyles.primaryGreen),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    // Campo de referências bíblicas
                    TextField(
                      controller: _verseController,
                      decoration: InputDecoration(
                        hintText: "Referências bíblicas (opcional)",
                        hintStyle:
                            const TextStyle(color: AppStyles.primaryGreen),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancelar",
                      style: TextStyle(
                          color: AppStyles.primaryGreen, fontSize: 16)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4549),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  onPressed: () async {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId == null || _notaController.text.trim().isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Por favor, digite uma anotação')),
                        );
                      }
                      return;
                    }

                    try {
                      final note = _notaController.text.trim();
                      final List<int> verseIds = _verseController.text
                          .split(',')
                          .map((s) => int.tryParse(s.trim()))
                          .whereType<int>()
                          .toList();

                      await Supabase.instance.client.from('bookmarks').insert({
                        'note_text': note,
                        'highlight_color': _corSelecionada,
                        'bookmark_type': 'note',
                        'verse_ids': verseIds,
                        'user_id': userId,
                        'created_at': DateTime.now().toIso8601String(),
                        'updated_at': DateTime.now().toIso8601String(),
                      });

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        await _carregarNotas();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao salvar nota: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editarNotaDialog(Map<String, dynamic> nota) {
    final TextEditingController _notaController =
        TextEditingController(text: nota['note_text'] ?? '');
    final TextEditingController _verseController = TextEditingController(
      text: nota['verse_ids'] != null && nota['verse_ids'].isNotEmpty
          ? nota['verse_ids'].join(', ')
          : '',
    );
    String _corSelecionada =
        nota['highlight_color'] ?? highlightColors.keys.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF1FFFD),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                "Editar Anotação",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: AppStyles.primaryGreen),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Seletor de cores
                    Wrap(
                      spacing: 12,
                      children: highlightColors.entries.map((entry) {
                        final isSelected = _corSelecionada == entry.key;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _corSelecionada = entry.key;
                            });
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppStyles.primaryGreen,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 20, color: Colors.black54)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Campo de texto da nota
                    TextField(
                      controller: _notaController,
                      decoration: InputDecoration(
                        hintText: "Digite sua anotação",
                        hintStyle:
                            const TextStyle(color: AppStyles.primaryGreen),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    // Campo de referências bíblicas
                    TextField(
                      controller: _verseController,
                      decoration: InputDecoration(
                        hintText: "Referências bíblicas (opcional)",
                        hintStyle:
                            const TextStyle(color: AppStyles.primaryGreen),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Cancelar",
                      style: TextStyle(
                          color: AppStyles.primaryGreen, fontSize: 16)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4549),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Salvar",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  onPressed: () async {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId == null || _notaController.text.trim().isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Por favor, digite uma anotação')),
                        );
                      }
                      return;
                    }

                    try {
                      final note = _notaController.text.trim();
                      final List<int> verseIds = _verseController.text
                          .split(',')
                          .map((s) => int.tryParse(s.trim()))
                          .whereType<int>()
                          .toList();

                      await _supabaseService.criarOuAtualizarNota(
                        id: nota['id'].toString(),
                        noteText: note,
                        highlightColor: _corSelecionada,
                        verseIds: verseIds,
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        await _carregarNotas();
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao atualizar nota: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removerNota(int id) async {
    await _supabaseService.deletarNota(id.toString());
    _carregarNotas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Anotações'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (cor) {
              setState(() => _filtroCor = cor);
              _carregarNotas();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Todas')),
              ..._cores.map((cor) => PopupMenuItem(
                    value: cor,
                    child: Text('Cor: $cor'),
                  )),
            ],
          ),
        ],
      ),
      body: _notas.isEmpty
          ? const Center(child: Text('Nenhuma anotação encontrada.'))
          : ListView.builder(
              itemCount: _notas.length,
              itemBuilder: (context, index) {
                final nota = _notas[index];
                return Card(
                  color:
                      highlightColors[nota['highlight_color']] ?? Colors.white,
                  child: ListTile(
                    title: Text(nota['note_text'] ?? ''),
                    subtitle: nota['verse_ids'] != null &&
                            nota['verse_ids'].isNotEmpty
                        ? Text('Versículos: ${nota['verse_ids'].join(', ')}')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editarNotaDialog(nota),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removerNota(nota['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoNovaNota(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
