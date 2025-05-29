// services/unsplash.dart
import 'dart:convert';
import 'package:http/http.dart' as http;


class UnsplashService {
  static const String _apiKey = 'Qulv2Y_O-trJmYE874cB7DjhHEtsJS2k-wkSgzFTkJ4';
  static const String _baseUrl = 'https://api.unsplash.com';

  Future<String> getRandomImage() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/photos/random?query=nature&orientation=landscape'),
        headers: {'Authorization': 'Client-ID $_apiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['urls']['regular'];
      }
      return '';
    } catch (e) {
      print('Erro ao buscar imagem: $e');
      return '';
    }
  }
}