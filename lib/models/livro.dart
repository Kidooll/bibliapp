import '../services/biblia_service.dart';

class Livro {
  final int id;
  final String abbrev;
  final String name;
  final int chapters;

  Livro({
    required this.id,
    required this.abbrev,
    required this.name,
    required this.chapters,
  });
  factory Livro.fromJson(Map<String, dynamic> json) {
    // Livros da API Bolls.life já vêm com o ID correto
    final id = json['id'] as int? ??
        json['book_id'] as int? ??
        json['bookid'] as int? ??
        1;

    final chapters = json['chapters'] is int
        ? json['chapters']
        : json['chapters'] is List
            ? (json['chapters'] as List).length
            : int.tryParse(json['chapters']?.toString() ?? '') ?? 1;

    return Livro(
      id: id,
      abbrev: json['abbrev']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      chapters: chapters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': id,
      'abbrev': abbrev,
      'name': name,
      'chapters': chapters,
    };
  }
}
