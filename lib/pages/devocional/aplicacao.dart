import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class TextoModal extends StatelessWidget {
  final String titulo;
  final String conteudo;

  const TextoModal({
    super.key,
    required this.titulo,
    required this.conteudo,
  });

  @override
  Widget build(BuildContext context) {
    return AppStyles.slideDialogAnimation(
      AlertDialog(
        backgroundColor: AppStyles.dialogBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(titulo, style: Theme.of(context).textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Text(conteudo, style: Theme.of(context).textTheme.bodyMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
