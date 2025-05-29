import 'package:flutter/material.dart';
import 'package:bibliapp/pages/biblia/comunidade_page.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'styles/styles.dart'; // Estilos e Animações

class DiarioPage extends StatelessWidget {
  const DiarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildTabBarView(),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppStyles.backgroundColor,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppStyles.avatarBackground,
            child: Text('A', style: TextStyle(color: AppStyles.primaryGreen)),
          ),
          const SizedBox(width: 12),
          Text('Diário', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.people_outline, color: AppStyles.primaryGreen),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ComunidadePage()),
          ),  
        ),
      ],
      bottom: _buildTabBar(),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      indicatorColor: AppStyles.primaryGreen,
      labelColor: AppStyles.primaryGreen,
      unselectedLabelColor: AppStyles.textBrownDark,
      tabs: [
        Tab(text: 'Tudo', icon: Icon(Icons.apps)),
        Tab(text: 'Destaques', icon: Icon(Icons.star_border)),
        Tab(text: 'Anotações', icon: Icon(Icons.edit_note)),
        Tab(text: 'Citações', icon: Icon(Icons.format_quote)),
      ],
    );
  }

  TabBarView _buildTabBarView() {
    return TabBarView(
      children: [
        TudoTab(),
        FavoritosTab(),
        AnotacoesTab(),
        Center(
            child: Text('Citações',
                style: TextStyle(color: AppStyles.textBrownDark))),
      ],
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddNoteDialog(context),
      backgroundColor: AppStyles.primaryGreen,
      child: const Icon(Icons.edit, color: Colors.white),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => NovaAnotacaoDialog(
        onSave: () {
          final anotacoesTabState =
              context.findAncestorStateOfType<_AnotacoesTabState>();
          anotacoesTabState?.loadAnotacoes();
        },
      ),
    );
  }
}

// ... (Mantenha apenas as classes TudoTab, FavoritosTab, AnotacoesTab e NovaAnotacaoDialog)
class FavoritosTab extends StatefulWidget {
  const FavoritosTab({super.key});

  @override
  _FavoritosTabState createState() => _FavoritosTabState();
}

class _FavoritosTabState extends State<FavoritosTab> {
  List<String> favoritos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavoritos();
  }

  Future<void> loadFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoritos = prefs.getStringList('favoritos') ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(color: AppStyles.primaryGreen));
    }

    return AnimationLimiter(
      child: ListView.builder(
        padding: AppStyles.defaultPadding,
        itemCount: favoritos.length,
        itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 375),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: AppStyles.diaryHighlight,
                child: Padding(
                  padding: AppStyles.tilePadding,
                  child: Text(favoritos[index],
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnotacoesTab extends StatefulWidget {
  const AnotacoesTab({super.key});

  @override
  _AnotacoesTabState createState() => _AnotacoesTabState();
}

class _AnotacoesTabState extends State<AnotacoesTab> {
  List<Map<String, dynamic>> anotacoes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAnotacoes();
  }

  Future<void> loadAnotacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final anotacoesStr = prefs.getStringList('anotacoes') ?? [];
    setState(() {
      anotacoes = anotacoesStr
          .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (anotacoes.isEmpty) {
      return Center(
          child: Text(
              'Nenhuma anotação ainda. Adicione uma anotação em uma passagem bíblica!'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: anotacoes.length,
      itemBuilder: (context, index) {
        final anot = anotacoes[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anot['texto'] ?? '', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                if (anot['referencia'] != null)
                  Text(anot['referencia'],
                      style: TextStyle(color: Colors.grey)),
                if (anot['data'] != null)
                  Text(anot['data'],
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NovaAnotacaoDialog extends StatefulWidget {
  final VoidCallback onSave;
  final Map<String, dynamic>? anotacao;
  final int? index;
  const NovaAnotacaoDialog(
      {super.key, required this.onSave, this.anotacao, this.index});

  @override
  _NovaAnotacaoDialogState createState() => _NovaAnotacaoDialogState();
}

class _NovaAnotacaoDialogState extends State<NovaAnotacaoDialog> {
  final TextEditingController _textoController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.anotacao != null) {
      _textoController.text = widget.anotacao!['texto'] ?? '';
      _referenciaController.text = widget.anotacao!['referencia'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.anotacao != null
              ? 'Editar Anotação'
              : 'Adicionar Anotação'),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textoController,
            decoration: InputDecoration(
              hintText: 'Inserir anotação...',
              border: InputBorder.none,
            ),
            maxLines: 3,
            autofocus: true,
          ),
          TextField(
            controller: _referenciaController,
            decoration: InputDecoration(
              labelText: 'Referência bíblica (opcional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final texto = _textoController.text.trim();
            if (texto.isNotEmpty) Share.share(texto);
          },
          child: Text('COMPARTILHAR'),
        ),
        ElevatedButton(
          onPressed: () async {
            final texto = _textoController.text.trim();
            if (texto.isEmpty) return;
            final referencia = _referenciaController.text.trim();
            final data = widget.anotacao != null
                ? widget.anotacao!['data']
                : DateTime.now().toString().substring(0, 16);
            final id = widget.anotacao != null
                ? widget.anotacao!['id']
                : DateTime.now().millisecondsSinceEpoch.toString();
            final bool pinned = widget.anotacao != null
                ? widget.anotacao!['pinned'] as bool
                : false;
            final anotacaoMap = {
              'id': id,
              'texto': texto,
              if (referencia.isNotEmpty) 'referencia': referencia,
              'data': data,
              'pinned': pinned,
            };
            final prefs = await SharedPreferences.getInstance();
            final anotacoesStr = prefs.getStringList('anotacoes') ?? [];
            if (widget.index != null) {
              anotacoesStr[widget.index!] = jsonEncode(anotacaoMap);
            } else {
              anotacoesStr.add(jsonEncode(anotacaoMap));
            }
            await prefs.setStringList('anotacoes', anotacoesStr);
            widget.onSave();
            Navigator.pop(context);
          },
          child: Text(widget.anotacao != null ? 'ATUALIZAR' : 'SALVAR'),
        ),
      ],
    );
  }
}

class TudoTab extends StatefulWidget {
  const TudoTab({super.key});

  @override
  _TudoTabState createState() => _TudoTabState();
}

class _TudoTabState extends State<TudoTab> {
  List<String> favoritos = [];
  List<Map<String, dynamic>> anotacoes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavoritos();
    loadAnotacoes();
  }

  Future<void> loadFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoritos = prefs.getStringList('favoritos') ?? [];
    });
  }

  Future<void> loadAnotacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsList = prefs.getStringList('anotacoes') ?? [];
    final temp = <Map<String, dynamic>>[];
    for (var i = 0; i < prefsList.length; i++) {
      final data = Map<String, dynamic>.from(jsonDecode(prefsList[i]));
      final id = data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final pinned = data['pinned'] ?? false;
      data['id'] = id;
      data['pinned'] = pinned;
      data['idx'] = i;
      temp.add(data);
    }
    setState(() {
      anotacoes = temp;
      isLoading = false;
    });
  }

  Future<void> togglePinned(Map<String, dynamic> anot) async {
    final prefs = await SharedPreferences.getInstance();
    final prefsList = prefs.getStringList('anotacoes') ?? [];
    final idx = anot['idx'] as int;
    final updated = Map<String, dynamic>.from(anot);
    final newPinned = !(updated['pinned'] as bool);
    updated['pinned'] = newPinned;
    prefsList[idx] = jsonEncode({
      'id': updated['id'],
      'texto': updated['texto'],
      if (updated['referencia'] != null) 'referencia': updated['referencia'],
      'data': updated['data'],
      'pinned': newPinned,
    });
    await prefs.setStringList('anotacoes', prefsList);
    loadAnotacoes();
  }

  void _editAnotacao(Map<String, dynamic> anot) {
    showDialog(
      context: context,
      builder: (context) => NovaAnotacaoDialog(
        onSave: () => loadAnotacoes(),
        anotacao: anot,
        index: anot['idx'] as int,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (favoritos.isEmpty && anotacoes.isEmpty) {
      return Center(child: Text('Nenhum favorito ou anotação ainda.'));
    }
    final pinnedList = anotacoes.where((a) => a['pinned'] == true).toList();
    final otherList = anotacoes.where((a) => a['pinned'] != true).toList();
    final totalCount = pinnedList.length + favoritos.length + otherList.length;
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index < pinnedList.length) {
          final anot = pinnedList[index];
          return _buildAnotacaoCard(anot);
        } else if (index < pinnedList.length + favoritos.length) {
          final fav = favoritos[index - pinnedList.length];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(fav, style: TextStyle(fontSize: 16)),
            ),
          );
        } else {
          final anot = otherList[index - pinnedList.length - favoritos.length];
          return _buildAnotacaoCard(anot);
        }
      },
    );
  }

  Widget _buildAnotacaoCard(Map<String, dynamic> anot) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppStyles.diaryHighlight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(anot['texto'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium),
            if (anot['referencia'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(anot['referencia'],
                    style: Theme.of(context).textTheme.labelLarge),
              ),
            Divider(color: AppStyles.accentBrown),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(anot['data'] ?? '',
                    style: Theme.of(context).textTheme.labelSmall),
                IconButton(
                  icon: Icon(
                    anot['pinned'] ? Icons.push_pin : Icons.push_pin_outlined,
                    color: anot['pinned']
                        ? AppStyles.pinColor
                        : AppStyles.accentBrown,
                  ),
                  onPressed: () => togglePinned(anot),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
