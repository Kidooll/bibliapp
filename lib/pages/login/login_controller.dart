import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? get currentUser => _supabase.auth.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loginComGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'io.supabase.flutter://login-callback',
      );
    } catch (e) {
      debugPrint("Erro no login com Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login com Google')),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint("Erro ao deslogar: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Escuta mudanças de autenticação
  void listenAuthChanges(void Function(AuthState) onChange) {
    _supabase.auth.onAuthStateChange.listen((data) {
      onChange(data.event as AuthState);
      notifyListeners();
    });
  }
}
