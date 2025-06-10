import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  UserModel? _currentUser;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;

  AuthService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint('AuthService - Iniciando inicialização');
      _isLoading = true;
      notifyListeners();

      // Verifica sessão atual
      final session = _supabase.auth.currentSession;
      _isAuthenticated = session != null;

      if (_isAuthenticated) {
        debugPrint('AuthService - Sessão encontrada');
        await _loadUserData();
      } else {
        debugPrint('AuthService - Nenhuma sessão encontrada');
      }

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      debugPrint('AuthService - Inicialização concluída');
    } catch (e) {
      debugPrint('AuthService - Erro na inicialização: $e');
      _isInitialized = true;
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Tenta buscar o perfil do usuário na tabela 'user_profiles'
        final response = await _supabase
            .from('user_profiles')
            .select()
            .eq('id', user.id) // Busca pelo novo 'id' que é UUID
            .maybeSingle(); // Usa maybeSingle para permitir 0 ou 1 resultado

        if (response != null) {
          _currentUser = UserModel.fromJson(response);
          debugPrint('AuthService - Dados do usuário carregados');
        } else {
          // Se o perfil não existir, cria um novo
          await _supabase.from('user_profiles').insert({
            'id': user.id,
            'email': user.email ?? 'sem_email@exemplo.com',
            'username': user.email?.split('@').first ?? 'Novo Usuário',
            'total_devotionals_read': 0,
            'total_xp': 0,
            'current_level': 1,
            'xp_to_next_level': 100,
            'coins': 0,
            'weekly_goal': 7,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          // Tenta buscar novamente após a inserção
          final newResponse = await _supabase
              .from('user_profiles')
              .select()
              .eq('id', user.id)
              .single();
          _currentUser = UserModel.fromJson(newResponse);
          debugPrint('AuthService - Novo perfil de usuário criado e carregado');
        }
      }
    } catch (e) {
      debugPrint('AuthService - Erro ao carregar dados do usuário: $e');
      _currentUser = null;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      debugPrint('AuthService - Iniciando login');
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _isAuthenticated = true;
        await _loadUserData();
        debugPrint('AuthService - Login realizado com sucesso');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService - Erro no login: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('AuthService - Iniciando logout');
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      _isAuthenticated = false;
      _currentUser = null;

      _isLoading = false;
      notifyListeners();
      debugPrint('AuthService - Logout realizado com sucesso');
    } catch (e) {
      debugPrint('AuthService - Erro no logout: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('AuthService - Iniciando login com Google');
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.bibliadevocional.biblia://login-callback',
      );

      _isLoading = false;
      notifyListeners();
      debugPrint('AuthService - Login com Google iniciado');
    } catch (e) {
      debugPrint('AuthService - Erro no login com Google: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      debugPrint('AuthService - Iniciando cadastro');
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('AuthService - Cadastro realizado com sucesso');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService - Erro no cadastro: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
