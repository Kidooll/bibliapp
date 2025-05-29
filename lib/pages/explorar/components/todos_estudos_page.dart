import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/firestore_service.dart';
import '../../estudo_detalhes_page.dart';


class TodosEstudosPage extends StatelessWidget {
  const TodosEstudosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os Estudos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getEstudos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum estudo disponível.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final titulo = data['title'] ?? 'Sem título';
              final conteudo = data['content'] ?? '';
              final imagem = data['image'] ??
                  'https://source.unsplash.com/400x300/?bible&sig=$index';

              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imagem,
                      width: 60, height: 60, fit: BoxFit.cover),
                ),
                title: Text(titulo),
                subtitle: Text(
                  conteudo.length > 50
                      ? '${conteudo.substring(0, 50)}...'
                      : conteudo,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EstudoDetalhesPage(
                        estudo: {
                          'id': doc.id,
                          'title': titulo,
                          'content': conteudo,
                          'image': imagem,
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
