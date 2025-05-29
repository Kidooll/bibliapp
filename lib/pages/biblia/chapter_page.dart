import 'package:flutter/material.dart';
import '/models/livro.dart';
import '/pages/biblia/verses_page.dart';
import 'package:bibliapp/styles/styles.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ChapterPage extends StatelessWidget {
  final Livro livro;
  
  final dynamic capitulo;

  const ChapterPage({
    super.key,
    required this.livro,
    required this.capitulo,
  });

  @override
  Widget build(BuildContext context) {
    if (livro.chapters <= 0) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppStyles.backgroundColor,
        ),
        backgroundColor: AppStyles.backgroundColor,
        body: Center(
          child: Text(
            'Livro inválido ou sem capítulos disponíveis',
            style: TextStyle(
              color: AppStyles.textBrownDark,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.backgroundColor,
        elevation: 0,
        title: Column(
          children: [
            Text(
              livro.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textBrownDark,
                  ),
            ),
            Text(
              '${livro.chapters} Capítulos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppStyles.textBrownDark.withOpacity(0.7),
                  ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: AppStyles.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: AnimationLimiter(
            child: ListView.builder(
              itemCount: livro.chapters,
              itemBuilder: (context, index) {
                final capitulo = index + 1;
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 300),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        elevation: 0,
                        color: AppStyles.backgroundColor,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppStyles.primaryGreen.withOpacity(0.3),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VersesPage(
                                  book: livro,
                                  chapter: capitulo,
                                  totalChapters: livro.chapters,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: Text(
                              'Capítulo $capitulo',
                              style: TextStyle(
                                color: AppStyles.textBrownDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
