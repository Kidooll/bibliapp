import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../pages/login/login_page.dart';

class AuthCheck extends StatelessWidget {
  final Widget child;

  const AuthCheck({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authService.isAuthenticated) {
          return const LoginScreen();
        }

        return child;
      },
    );
  }
}
