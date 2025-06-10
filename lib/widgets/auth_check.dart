import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../pages/login/login_page.dart';

class AuthCheck extends StatelessWidget {
  final Widget child;

  const AuthCheck({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        debugPrint('AuthCheck - isInitialized: ${authService.isInitialized}');
        debugPrint('AuthCheck - isLoading: ${authService.isLoading}');
        debugPrint(
            'AuthCheck - isAuthenticated: ${authService.isAuthenticated}');

        // Mostra loading enquanto inicializa
        if (!authService.isInitialized || authService.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Carregando...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5E9EA0),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Redireciona para login se não estiver autenticado
        if (!authService.isAuthenticated) {
          debugPrint('AuthCheck - Redirecionando para LoginScreen');
          return const LoginScreen();
        }

        // Retorna o conteúdo principal se estiver autenticado
        debugPrint('AuthCheck - Retornando conteúdo principal');
        return child;
      },
    );
  }
}
