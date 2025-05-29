import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../../services/firestore_service.dart';
import '../../../pages/estudo_detalhes_page.dart';
import 'todos_estudos_page.dart';



class EstudosSection extends StatelessWidget {
  const EstudosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = Provider.of<FirestoreService>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          SizedBox(
            height: 180,
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.getEstudos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Text('Nenhum estudo encontrado.'),
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final titulo = data['title'] ?? 'Sem título';
                    final conteudo = data['content'] ?? '';
                    // Imagem fixa do Unsplash para todos os estudos
                    final imagem =
                        'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?q=80&w=1000';

                    print(
                        'Título: $titulo, Conteúdo: ${conteudo.length > 50 ? conteudo.substring(0, 50) + '...' : conteudo}'); // Debug

                    return GestureDetector(
                      onTap: () {
                        print('Clicou no estudo: $titulo'); // Debug
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EstudoDetalhesPage(
                              estudo: {
                                'title': titulo,
                                'content': conteudo,
                                'image': imagem,
                                'id': doc.id,
                              },
                            ),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 140,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imagem,
                                height: 100,
                                width: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                      'Erro ao carregar imagem: $error'); // Debug
                                  return Container(
                                    height: 100,
                                    width: 140,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image, size: 40),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Estudos', style: Theme.of(context).textTheme.titleLarge),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TodosEstudosPage(),
              ),
            );
            // Ver mais estudos
          },
          child: const Text('Ver mais'),
        )
      ],
    );
  }
}
