import 'dart:convert';
import 'package:http/http.dart' as http;

class BibliaService {
  
  static const String baseUrl = 'https://bolls.life';
  static const List<String> versoes = ['NTLH', 'NVT', 'NAA'];
  Future<List<dynamic>> getLivros(String versao) async {
    try {
      print('Carregando livros para versão: $versao');
      final response = await http
          .get(Uri.parse('$baseUrl/get-books/$versao/'))
          .timeout(Duration(seconds: 10));
          
      if (response.statusCode != 200) {
        throw Exception('Erro HTTP ${response.statusCode}');
      }
      
      return json.decode(response.body);
    } catch (e) {
      print('Erro crítico no service: $e');
      throw Exception('Verifique sua conexão e tente novamente');
    }
  }

  Future<List<dynamic>> getCapitulo(
      String versao, int livro, int capitulo) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get-text/$versao/$livro/$capitulo/'))
          .timeout(Duration(seconds: 10));
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Falha ao carregar capítulo');
    }
  }

  static Future<Map<String, String>> compararVersoes(
      int bookId, int chapter, int verse) async {
    try {
      final textos = <String, String>{};
      final futures = versoes.map(
          (v) => http.get(Uri.parse('$baseUrl/get-text/$v/$bookId/$chapter/')));
      final responses = await Future.wait(futures);

      for (int i = 0; i < responses.length; i++) {
        final versiculo = json.decode(responses[i].body).firstWhere(
              (el) => el['verse'] == verse,
              orElse: () => null,
            );
        textos[versoes[i]] = versiculo?['text'] ?? 'Não encontrado';
      }
      return textos;
    } catch (e) {
      throw Exception('Falha na comparação');
    }
  }
}
