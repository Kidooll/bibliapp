import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../services/study_service.dart';
import '../../../pages/estudo_detalhes_page.dart';
import 'todos_estudos_page.dart';



class EstudosSection extends StatelessWidget {
  const EstudosSection({super.key});

  @override
  Widget build(BuildContext context) {
    final studyService = Provider.of<StudyService>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          SizedBox(
            height: 180,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: studyService.getEstudos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final estudos = snapshot.data!;

                if (estudos.isEmpty) {
                  return Center(
                    child: Text('Nenhum estudo encontrado.'),
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: estudos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final estudo = estudos[index];
                    final titulo = estudo['title'] ?? 'Sem título';
                    final conteudo = estudo['content'] ?? '';
                    final tipo = estudo['type'] ?? 'Estudo';
                    final dataCriacao = estudo['created_at'] != null
                        ? DateTime.parse(estudo['created_at'])
                        : DateTime.now();
                    final dataFormatada = '${dataCriacao.day}/${dataCriacao.month}/${dataCriacao.year}';
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
                                'id': estudo['id'].toString(),
                                'type': tipo,
                                'created_at': estudo['created_at'],
                                'tags': estudo['tags'],
                                'metadata': estudo['metadata'],
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
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tipo,
                                    style: TextStyle(fontSize: 10, color: Colors.green.shade800),
                                  ),
                                ),
                                Text(
                                  dataFormatada,
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
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
