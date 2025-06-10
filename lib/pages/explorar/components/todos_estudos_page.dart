import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/study_service.dart';
import '../../estudo_detalhes_page.dart';


class TodosEstudosPage extends StatelessWidget {
  const TodosEstudosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final studyService = Provider.of<StudyService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os Estudos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: studyService.getEstudos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final estudos = snapshot.data ?? [];

          if (estudos.isEmpty) {
            return const Center(child: Text('Nenhum estudo disponível.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: estudos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final estudo = estudos[index];
              final titulo = estudo['title'] ?? 'Sem título';
              final conteudo = estudo['content'] ?? '';
              final tipo = estudo['type'] ?? 'Estudo';
              final dataCriacao = estudo['created_at'] != null
                  ? DateTime.parse(estudo['created_at'])
                  : DateTime.now();
              final dataFormatada = '${dataCriacao.day}/${dataCriacao.month}/${dataCriacao.year}';
              final imagem = estudo['image'] ??
                  'https://source.unsplash.com/400x300/?bible&sig=$index';

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EstudoDetalhesPage(
                          estudo: {
                            'id': estudo['id'] ?? '',
                            'title': titulo,
                            'content': conteudo,
                            'image': imagem,
                            'type': tipo,
                            'created_at': estudo['created_at'],
                            'tags': estudo['tags'],
                            'metadata': estudo['metadata'],
                          },
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imagem,
                            width: 70, 
                            height: 70, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image, size: 30),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                conteudo.length > 50
                                    ? '${conteudo.substring(0, 50)}...'
                                    : conteudo,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
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
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
