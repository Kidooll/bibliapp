import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../styles/styles.dart';

class VerseActionsModal extends StatelessWidget {
  final int verseId;
  final String text;
  final bool isFavorite;
  final String? highlightColor;
  final VoidCallback onRefresh;

  static final supabase = Supabase.instance.client;

  static const List<String> colors = [
    '#FFF9C4', // amarelo
    '#B2EBF2', // azul claro
    '#FFCCBC', // laranja claro
    '#C8E6C9', // verde claro
    '#E1BEE7', // lilás
  ];

  const VerseActionsModal({
    super.key,
    required this.verseId,
    required this.text,
    required this.isFavorite,
    this.highlightColor,
    required this.onRefresh,
  });

  Future<void> _toggleFavorite(BuildContext context) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      if (isFavorite) {
        await supabase
            .from('bookmarks')
            .delete()
            .eq('user_id', user.id)
            .overlaps('verse_ids', [verseId]).eq('bookmark_type', 'favorite');
      } else {
        await supabase.from('bookmarks').upsert({
          'user_id': user.id,
          'verse_ids': [verseId],
          'bookmark_type': 'favorite',
        });
      }

      onRefresh();
    } catch (e) {
      debugPrint('Erro ao favoritar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao favoritar versículo')),
        );
      }
    }
  }

  Future<void> _setHighlight(BuildContext context, String hex) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Se clicar na mesma cor, remove o highlight
      if (hex == highlightColor) {
        await supabase
            .from('bookmarks')
            .delete()
            .eq('user_id', user.id)
            .overlaps('verse_ids', [verseId]).eq('bookmark_type', 'highlight');

        onRefresh(); // Atualiza o estado
        Navigator.pop(context);
        return;
      }

      // Remove highlight existente se houver
      if (highlightColor != null) {
        await supabase
            .from('bookmarks')
            .delete()
            .eq('user_id', user.id)
            .overlaps('verse_ids', [verseId]).eq('bookmark_type', 'highlight');
      }

      // Adiciona novo highlight
      await supabase.from('bookmarks').upsert({
        'user_id': user.id,
        'verse_ids': [verseId],
        'bookmark_type': 'highlight',
        'highlight_color': hex,
      });

      onRefresh(); // Atualiza o estado
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao destacar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao destacar versículo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Wrap(
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Text(
            'O que deseja fazer?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Cores para destaque
          Wrap(
            spacing: 12,
            children: colors.map((hex) {
              final isSelected = hex == highlightColor;
              return GestureDetector(
                onTap: () => _setHighlight(context, hex),
                child: CircleAvatar(
                  backgroundColor: Color(int.parse('0xFF${hex.substring(1)}')),
                  radius: 18,
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.black)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Botões de ação
          ListTile(
            leading: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : Colors.grey,
            ),
            title: Text(isFavorite ? 'Remover dos Favoritos' : 'Favoritar'),
            onTap: () => _toggleFavorite(context),
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copiar texto'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: text));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Texto copiado')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Compartilhar'),
            onTap: () {
              Share.share(text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
