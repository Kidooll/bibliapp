import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../pages/login/register_page.dart';
import '../../styles/styles.dart';

InputDecoration customInputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> loginWithEmail() async {
    try {
      final authService = context.read<AuthService>();
      await authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Erro'),
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final authService = context.read<AuthService>();
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Erro'),
            content: Text(e.toString()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    if (authService.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF8F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 10),
              const Text("Olá!!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Bem vindo ao BIBLIApp",
                  style: TextStyle(fontSize: 14)),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Login",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration:
                    customInputDecoration("Digite aqui seu email", Icons.email),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:
                    customInputDecoration("Digite aqui sua senha", Icons.lock),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {}, // Implementar recuperação se quiser
                  child: const Text("Esqueci minha senha"),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: loginWithEmail,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: AppStyles.primaryGreen,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 60),
                ),
                child: const Text("Login",
                    style: TextStyle(
                        fontSize: 16,
                        color: AppStyles.backgroundColor,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1),
              const Text("Ou faça login com"),
              const SizedBox(height: 10),
              IconButton(
                icon: Image.asset('assets/icons/google.png', height: 40),
                onPressed: loginWithGoogle,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()));
                },
                child: const Text("Não tem uma conta? Crie a sua."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
