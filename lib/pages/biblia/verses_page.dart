import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../widgets/bible_verse_tile.dart';
import '../../styles/styles.dart';
import '../../utils/hex_color.dart';
import '../../widgets/verse_actions_modal.dart';
import '../../providers/biblia_provider.dart';
import 'chapter_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/livro.dart';

class VersesPage extends StatefulWidget {
  final Livro book;
  final int chapter;
  final int totalChapters;

  const VersesPage({
    super.key,
    required this.book,
    required this.chapter,
    required this.totalChapters,
  });

  @override
  State<VersesPage> createState() => _VersesPageState();
}

class _VersesPageState extends State<VersesPage> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> verses = [];
  Map<int, String> highlightColors = {};
  Map<int, String> cleanTextCache = {};
  bool isLoading = true;
  String? errorMessage;
  final supabase = Supabase.instance.client;
  double textSize = 16.0;

  String cleanVerseText(String text) {
    text = text.replaceAll(RegExp(r'<sup[^>]*>.*?<\/sup>'), '');
    text = text.replaceAll(RegExp(r'<br\s*\/?>'), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchVersesAndBookmarks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadNextChapter();
    }
  }

  void _loadNextChapter() {
    debugPrint('📖 Carregando próximo capítulo...');
    debugPrint('📖 Capítulo atual: ${widget.chapter}');
    debugPrint('📖 Total de capítulos: ${widget.totalChapters}');

    if (widget.chapter < widget.totalChapters) {
      debugPrint('📖 Navegando para capítulo ${widget.chapter + 1}');

      // Use pushReplacement to replace the current page with the new one
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => VersesPage(
            book: widget.book,
            chapter: widget.chapter + 1,
            totalChapters: widget.totalChapters,
          ),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  Future<void> fetchVersesAndBookmarks() async {
    if (!mounted) return;

    // Só mostra o loading se for a primeira carga
    if (verses.isEmpty) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final provider = Provider.of<BibliaProvider>(context, listen: false);
      final version = provider.selectedVersion;

      debugPrint('📚 Carregando livro: ${widget.book.name}');
      // Ensure we have valid book ID
      final bookId = widget.book.id;
      debugPrint('📚 Book ID: $bookId');
      debugPrint('📚 Abreviação: ${widget.book.abbrev}');

      // Format URL according to Bolls.life API documentation
      final uri = Uri.parse(
          'https://bolls.life/get-text/$version/$bookId/${widget.chapter}/');

      debugPrint('📚 URL da requisição: $uri');

      // Fetch verses
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Erro ao carregar versículos: ${response.statusCode}');
      }

      final body = json.decode(response.body);
      final List<dynamic> verseList =
          body is List ? body : (body['verses'] ?? []);

      // Process verses
      final processedVerses = verseList
          .map((v) {
            final pk = v['pk'];
            final id = pk is int ? pk : int.tryParse(pk.toString()) ?? -1;
            if (id != -1) {
              cleanTextCache[id] = cleanVerseText(v['text']);
            }
            return Map<String, dynamic>.from({...v, 'pk': id});
          })
          .where((v) => v['pk'] != -1)
          .toList();

      // Get bookmarks if user is logged in
      final user = supabase.auth.currentUser;
      final newColors = <int, String>{};

      if (user != null) {
        try {
          final bookmarksResponse = await supabase
              .from('bookmarks')
              .select()
              .eq('user_id', user.id)
              .inFilter('bookmark_type', ['highlight']);

          for (final item in bookmarksResponse) {
            final List<dynamic> verseIds = item['verse_ids'] ?? [];

            for (final verseId in verseIds) {
              final int id = verseId is int
                  ? verseId
                  : int.tryParse(verseId.toString()) ?? -1;
              if (id == -1) continue;

              if (item['bookmark_type'] == 'highlight') {
                final color = item['highlight_color']?.toString();
                if (color != null) newColors[id] = color;
              }
            }
          }
        } catch (e) {
          debugPrint('Erro ao carregar bookmarks: $e');
          // Continue without bookmarks
        }
      }

      if (!mounted) return;

      // Atualiza o estado de forma otimizada
      if (mounted) {
        setState(() {
          verses = processedVerses;
          highlightColors = newColors;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar capítulo: $e');
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Erro ao carregar o capítulo. Por favor, tente novamente.';
      });
    }
  }

  Future<void> deleteAllUserBookmarks() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase.from('bookmarks').delete().eq('user_id', user.id);
      debugPrint('Todos os bookmarks do usuário foram removidos.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos os bookmarks foram removidos.')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao deletar bookmarks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao deletar bookmarks: $e')),
        );
      }
    }
  }

  void updateBookmark(int verseId, String type, {String? color}) {
    setState(() {
      if (type == 'highlight') {
        if (color == null || color == highlightColors[verseId]) {
          // Remove o highlight se a cor for nula ou igual à atual
          highlightColors.remove(verseId);
        } else {
          // Atualiza com a nova cor
          highlightColors[verseId] = color;
        }
      }
    });
  }

  void _handleBackNavigation(BuildContext context) {
    debugPrint('🔙 Voltando da página de versículos...');
    debugPrint('🔙 Livro atual: ${widget.book.name}');
    debugPrint('🔙 Capítulo atual: ${widget.chapter}');

    // Retorna para a página anterior (BookListPage)
    Navigator.pop(context);

    // Depois que retornar, abre o ChapterPage com um pequeno delay
    Future.delayed(Duration(milliseconds: 100), () {
      if (context.mounted) {
        final provider = Provider.of<BibliaProvider>(context, listen: false);
        provider.openChaptersModal(context, widget.book);
      }
    });
  }

  Future<void> _showVerseActions(Map<String, dynamic> verse) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => VerseActionsModal(
        verseId: verse['pk'] as int,
        text: cleanTextCache[verse['pk']] ?? cleanVerseText(verse['text']),
        highlightColor: highlightColors[verse['pk']],
        onRefresh: () async {
          // Força uma nova busca dos destaques
          await fetchVersesAndBookmarks();
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );

    // Atualiza a UI após fechar o modal apenas se ainda estiver montado
    if (mounted) {
      await fetchVersesAndBookmarks();
    }
  }

  void _compareVerse(int verseNumber) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comparação em breve!')),
    );
  }

  Widget _buildVerseItem(Map<String, dynamic> verse) {
    final verseNumber = verse['verse'] as int;
    final verseKey = verse['pk'] as int;
    final highlightColor = highlightColors[verseKey];

    return BibleVerseTile(
      verseText: cleanTextCache[verseKey] ?? cleanVerseText(verse['text']),
      verseNumber: verseNumber,
      onHighlightPressed: () => _showHighlightOptions(verseKey, highlightColor),
      onComparePressed: () => _compareVerse(verseNumber),
      textSize: 16.0,
      highlightColor: highlightColor != null ? Color(int.parse(highlightColor.replaceAll('#', '0xFF'))) : null,
    );
  }

  void _showHighlightOptions(int verseKey, String? currentColor) {
    _showVerseActions({
      'pk': verseKey,
      'text': cleanTextCache[verseKey] ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.book.name} ${widget.chapter}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppStyles.textBrownDark,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppStyles.backgroundColor,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            errorMessage = null;
                            isLoading = true;
                          });
                          fetchVersesAndBookmarks();
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : verses.isEmpty
                  ? const Center(
                      child: Text('Nenhum versículo encontrado'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: verses.length,
                      itemBuilder: (context, index) {
                        final verse = verses[index];
                        return _buildVerseItem(verse);
                      },
                    ),
    );
  }
}
