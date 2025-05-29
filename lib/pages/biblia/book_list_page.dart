import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/biblia_provider.dart';
import 'book_tile.dart';
import 'package:bibliapp/styles/styles.dart'; // Importe os estilos
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../models/livro.dart';

void _showRandomVerse(BuildContext context) async {
  final provider = Provider.of<BibliaProvider>(context, listen: false);

  final data = await provider.fetchRandomVerse();
  if (data['verse'] != null) {
    showDialog(
      context: context,
      builder: (context) => AnimationLimiter(
        child: AlertDialog(
          backgroundColor: AppStyles.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: AnimationConfiguration.staggeredList(
            position: 0,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Center(
                  child: Text('Sugestão de Leitura',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppStyles.primaryGreen,
                            fontWeight: FontWeight.bold,
                          )),
                ),
              ),
            ),
          ),
          content: AnimationConfiguration.staggeredList(
            position: 1,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cabeçalho com livro e referência
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: AppStyles.accentBrown.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Text(
                            data['book']['name'],
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppStyles.primaryGreen,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data['chapter']}:${data['verse']['verse']}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppStyles.primaryGreen,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Texto do versículo
                    Html(
                      data: data['verse']['text'],
                      style: {
                        "body": Style(
                          textAlign: TextAlign.justify,
                          fontSize: FontSize(16.0),
                          fontFamily: 'Merriweather',
                          color: AppStyles.primaryGreen,
                        ),
                      },
                    ),

                    // Botão de fechar
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Fechar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BibliaProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.books.isEmpty && !provider.isLoading) {
        provider.initialize();
      }
    });

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppStyles.backgroundColor,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppStyles.avatarBackground,
              child: Text('A'),
            ),
            const SizedBox(width: 12),
            Text('Bíblia', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border:
                    // ignore: deprecated_member_use
                    Border.all(color: AppStyles.borderColor.withOpacity(0.1)),
              ),
              child: DropdownButton<String>(
                value: provider.selectedVersion,
                underline: const SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppStyles.primaryGreen),
                items: ['NAA', 'NTLH', 'NVT']
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v,
                            style: Theme.of(context).textTheme.labelLarge),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    provider.selectedVersion = v;
                    provider.fetchBooks();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Botões de AT/NT
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    provider.selectedTestament = 'AT';
                    provider.filterBooks();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        left: 16, right: 4, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: AppStyles.testamentButtonDecoration(
                        provider.selectedTestament == 'AT'),
                    child: Center(
                      child: Text('ANTIGO TESTAMENTO',
                          style: TextStyle(
                            color: provider.selectedTestament == 'AT'
                                ? Colors.white
                                : AppStyles.textBrownDark,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    provider.selectedTestament = 'NT';
                    provider.filterBooks();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                        right: 16, left: 4, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: AppStyles.testamentButtonDecoration(
                        provider.selectedTestament == 'NT'),
                    child: Center(
                      child: Text('NOVO TESTAMENTO',
                          style: TextStyle(
                            color: provider.selectedTestament == 'NT'
                                ? Colors.white
                                : AppStyles.primaryGreen,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Barra de pesquisa
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: AppStyles.searchBarDecoration,
            child: Row(
              children: [
                Icon(Icons.search, color: AppStyles.primaryGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar na Bíblia',
                      border: InputBorder.none,
                      hintStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                // ignore: deprecated_member_use
                                color: AppStyles.textBrownDark.withOpacity(0.6),
                              ),
                    ),
                    onChanged: (value) {
                      provider.searchText = value;
                      provider.filterBooks();
                    },
                  ),
                ),
              ],
            ),
          ),
          // Lista de livros
          Expanded(
            child: provider.isLoading
                ? LoadingShimmer()
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: provider.filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = provider.filteredBooks[index];
                      return BookTile(book: book);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRandomVerse(context),
        backgroundColor: AppStyles.primaryGreen,
        child: Icon(Icons.bookmark_border, color: Colors.white),
      ),
    );
  }
}
