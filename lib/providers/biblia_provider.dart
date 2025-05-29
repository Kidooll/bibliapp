import 'package:bibliapp/models/livro.dart';
import 'package:flutter/material.dart';
import '../services/biblia_service.dart';
import '../pages/biblia/chapter_page.dart';

class BibliaProvider with ChangeNotifier {
  final BibliaService _service = BibliaService();
  List<Livro> books = [];
  List<Livro> filteredBooks = [];
  bool isLoading = true;
  String selectedVersion = 'NAA';
  String selectedTestament = 'AT';
  String searchText = '';
  
  BibliaProvider() {
    initialize();
  }

  void initialize() {
    if (books.isEmpty) {
      fetchBooks();
    }
  }

  // Carrega livros com tratamento de erro
  String errorText = '';

  Future<void> fetchBooks() async {
    isLoading = true;
    errorText = '';
    notifyListeners();

    try {
      final data = await _service.getLivros(selectedVersion);
      books = data.map<Livro>((json) => Livro.fromJson(json)).toList();
      
      if (books.isEmpty) {
        errorText = 'Nenhum livro encontrado para esta versão';
      }
      filterBooks();
    } catch (e) {
      print("Erro ao carregar livros: $e");
      errorText = 'Erro ao carregar livros. Por favor, tente novamente.';
      books = [];
      filterBooks();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  // Filtra livros
  void filterBooks() {
    filteredBooks = books.where((book) {
      final bookName = book.name.toLowerCase();
      
      // Verifica se o livro tem capítulos válidos
      final hasValidChapters = book.chapters > 0;
      
      // Para o Antigo Testamento, consideramos os primeiros 39 livros
      // Como não temos chronorder, usamos o ID como referência
      final isTestamentMatch = selectedTestament == 'AT' 
          ? book.id <= 39 
          : book.id > 39;
          
      final hasSearchMatch = bookName.contains(searchText.toLowerCase());
      
      return hasValidChapters && isTestamentMatch && hasSearchMatch;
    }).toList();
    notifyListeners();
  }
  
  // Retorna dados para a UI construir a modal
  Map<String, dynamic> getChaptersData(Livro book) {
    return {
      'chapters': List.generate(book.chapters, (index) => index + 1),
      'bookId': book.id,
      'bookName': book.name,
    };
  }

  // Retorna dados do versículo aleatório (UI decide como exibir)
  Future<Map<String, dynamic>> fetchRandomVerse() async {
    try {
      if (books.isEmpty) {
        await fetchBooks();
      }
      if (books.isEmpty) return {};

      final randomBook = (List<Livro>.from(books)..shuffle()).first;
      final randomChapter = (List.generate(randomBook.chapters, (i) => i + 1)..shuffle()).first;
      final verses = await _service.getCapitulo(selectedVersion, randomBook.id, randomChapter);

      return {
        'book': randomBook.toJson(),
        'chapter': randomChapter,
        'verse': verses.isNotEmpty ? (List.from(verses)..shuffle()).first : null,
      };
    } catch (e) {
      print("Erro no versículo aleatório: $e");
      return {};
    }
  }


void openChaptersModal(BuildContext context, dynamic bookData) {
  try {
    final livro = bookData is Livro ? bookData : Livro.fromJson(bookData as Map<String, dynamic>);
    final chaptersData = getChaptersData(livro);
    
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        transitionAnimationController: AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: Navigator.of(context),
        ),
        builder: (_) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOutCubic,
          )),
          child: ChapterPage(
            livro: livro,
            capitulo: chaptersData['chapters'],
          ),
        ),
      );
    }
  } catch (e) {
    debugPrint('Error in openChaptersModal: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao abrir os capítulos')),
    );
  }
}
}

extension on Map<String, dynamic> {
  get first => null;

  shuffle() {}
}

extension on Livro {
  int get bookId => id;
}
