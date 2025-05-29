import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;
  static const String _textSizeKey = 'textSize';
  static const double _defaultTextSize = 17.0;

  static Future<void> _init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  static Future<double> loadTextSize() async {
    try {
      await _init();
      return _prefs?.getDouble(_textSizeKey) ?? _defaultTextSize;
    } catch (e) {
      return _defaultTextSize;
    }
  }

  static Future<void> saveTextSize(double size) async {
    try {
      await _init();
      await _prefs?.setDouble(_textSizeKey, size);
    } catch (e) {
      // Silenciosamente falha se não conseguir salvar
    }
  }

  static Future<List<String>> loadFavoritos() async {
    try {
      await _init();
      return _prefs?.getStringList('favoritos') ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveFavoritos(List<String> ids) async {
    try {
      await _init();
      await _prefs?.setStringList('favoritos', ids);
    } catch (e) {
      // Silenciosamente falha se não conseguir salvar
    }
  }
}
