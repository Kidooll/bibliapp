// home_page.dart (redesenhado)
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../styles/styles.dart';
import '../services/firebase.dart';
import '../services/unsplash.dart';
import '../pages/devocional/devocional_tela.dart';
import '../pages/devocional/citacao_tela.dart';
import 'package:intl/intl.dart'; // Para formatação de datas
import 'package:intl/date_symbol_data_local.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseDevotionalService _devotionalService =
      FirebaseDevotionalService();
  final UnsplashService _unsplashService = UnsplashService();
  late Future<Map<String, dynamic>?> _devotionalFuture;
  late Future<String> _imageFuture;
  // ignore: unused_field, prefer_final_fields
  DateTime _selectedDate = DateTime.now();

  // Lista de dias para o calendário
  late List<DateTime> _calendarDays;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting(
        'pt_BR', null); // Inicializa a formatação de data para português
    _devotionalFuture = _devotionalService.getDailyDevotional();
    _imageFuture = _unsplashService.getRandomImage();
    _initCalendarDays();
  }

  void _initCalendarDays() {
    // Encontra o domingo da semana atual
    final now = DateTime.now();
    // Subtrai o dia da semana (0=domingo, 1=segunda, etc.) para chegar no domingo
    final startDate = now.subtract(Duration(days: now.weekday % 7));

    // Gera 7 dias a partir do domingo (de domingo a sábado)
    _calendarDays =
        List.generate(7, (index) => startDate.add(Duration(days: index)));
  }

  Future<void> formatDates() async {
    // Função vazia pois a inicialização já é suficiente
  }

  // Construir o header com perfil e título
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar do perfil com letra "A"
          CircleAvatar(
            radius: 28,
            backgroundColor:
                const Color(0xFF5E9EA0), // Cor turquesa vista na imagem
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Título do app
          Text(
            'Adoração Diária',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
          ),
          const Spacer(),
          // Ícone de notificação
          IconButton(
            icon: const Icon(Icons.notifications_none,
                size: 28, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // Card de progresso do trabalho/missões
  Widget _buildProgressCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF5E9EA0), // Cor turquesa vista na imagem
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título "Bom trabalho!"
          const Text(
            'Bom trabalho!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Divisor horizontal branco
          Container(
            height: 2,
            width: 250,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          // Texto de missões completas
          const Row(
            children: [
              Text(
                '0/2 missões completas hoje!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              // Aqui você poderia adicionar a ilustração de montanhas
            ],
          ),
        ],
      ),
    );
  }

  // Calendário mensal
  Widget _buildCalendar() {
    final now = DateTime.now();
    final weekdayFormat = DateFormat('E', 'pt_BR');
    final dayFormat = DateFormat('d');
    final monthFormat = DateFormat('MMMM', 'pt_BR');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do mês com seta
          Row(
            children: [
              Text(
                monthFormat.format(now).capitalize(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
          const SizedBox(height: 12),
          // Dias da semana + números
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_calendarDays.length, (index) {
              final day = _calendarDays[index];
              final isSelected = day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;

              return Container(
                width: 40,
                height: 65,
                decoration: isSelected
                    ? BoxDecoration(
                        color: const Color(0xFF5E9EA0),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      weekdayFormat.format(day)[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dayFormat.format(day),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Card da citação do dia
  Widget _buildQuoteCard(Map<String, dynamic> devotional, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5E9EA0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone e título
          Row(
            children: [
              const Icon(Icons.format_quote, color: Colors.white, size: 26),
              const SizedBox(width: 12),
              const Text(
                'Citação do Dia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CitacaoTela(
                      imagemUrl: imageUrl,
                      citacao: devotional['quote'],
                      autor: devotional['author'] ?? 'Autor Desconhecido',
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text(
                  'Ler',
                  style: TextStyle(
                    color: Color(0xFF5E9EA0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Texto da citação
          Text(
            devotional['quote'] ??
                'A vida é um eco. O que você envia volta para você.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Linha divisória
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.5),
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
        ],
      ),
    );
  }

  // Card do devocional
  Widget _buildDevotionalCard(Map<String, dynamic> devotional) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone e título
          Row(
            children: [
              const Icon(Icons.menu_book, color: Color(0xFF1F4549), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Devocional de hoje',
                style: TextStyle(
                  color: Color(0xFF1F4549),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DevocionalTela(devocional: devotional),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  foregroundColor: const Color(0xFF1F4549),
                  side: const BorderSide(color: Color(0xFF5E9EA0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text(
                  'Ler',
                  style: TextStyle(
                    color: Color(0xFF5E9EA0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Título do devocional
          Text(
            devotional['title'] ?? 'Renovação a Cada Dia',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Card do versículo do dia
  Widget _buildVerseCard(Map<String, dynamic> devotional) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone e título
          Row(
            children: [
              const Icon(Icons.book, color: Color(0xFF1F4549), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Versículo do Dia',
                style: TextStyle(
                  color: Color(0xFF1F4549),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Texto do versículo
          Text(
            devotional['verso'] ??
                'O Senhor é bom para que esperam nele, para a alma que o busca.',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF1F4549),
            ),
          ),
          const SizedBox(height: 10),
          // Referência do versículo
          Text(
            devotional['verso2'] ?? 'Lamentações 3:25',
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Color(0xFF1F4549),
            ),
          ),
        ],
      ),
    );
  }

  // Imagem destacada
  Widget _buildFeatureImage() {
    return FutureBuilder<String>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar imagem'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma imagem disponível'));
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: CachedNetworkImageProvider(snapshot.data!),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  // Card combinado
  Widget _buildCombinedCard(Map<String, dynamic> devotional, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF5E9EA0), // Cor do card
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Citação do Dia + Botão
          Row(
            children: [
              const Text(
                'Citação do Dia',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: imageUrl == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CitacaoTela(
                              imagemUrl: imageUrl,
                              citacao: devotional['quote'] ??
                                  'A vida é um eco. O que você envia volta para você.',
                              autor:
                                  devotional['author'] ?? 'Autor Desconhecido',
                            ),
                          ),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text(
                  'Ler',
                  style: TextStyle(
                    color: Color(0xFF5E9EA0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            devotional['quote'] ??
                'A vida é um eco. O que você envia volta para você.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          // Linha de separação
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.5),
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          // Devocional de hoje + Botão
          Row(
            children: [
              const Text(
                'Devocional de hoje',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DevocionalTela(devocional: devotional),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text(
                  'Ler',
                  style: TextStyle(
                    color: Color(0xFF5E9EA0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            devotional['title'] ?? 'Renovação a Cada Dia',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          // Linha de separação
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.5),
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          // Versículo do Dia
          const Text(
            'Versículo do Dia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            devotional['verso'] ??
                'O Senhor é bom para que esperam nele, para a alma que o busca.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            devotional['verso2'] ?? 'Lamentações 3:25',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7), // Fundo azul clarinho
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _devotionalFuture,
          builder: (context, devotionalSnapshot) {
            if (devotionalSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (devotionalSnapshot.hasError || !devotionalSnapshot.hasData) {
              return Center(
                child: Text(
                  'Nenhum devocional encontrado',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final devotional = devotionalSnapshot.data!;

            return FutureBuilder<String>(
              future: _imageFuture,
              builder: (context, imageSnapshot) {
                return Stack(
                  children: [
                    // Conteúdo principal com scroll
                    ListView(
                      children: [
                        const SizedBox(height: 8),
                        _buildHeader(),
                        _buildProgressCard(),
                        _buildCalendar(),
                        _buildCombinedCard(
                            devotional,
                            imageSnapshot
                                .data), // Novo card combinado com botões
                        _buildFeatureImage(),
                        // Espaço para a navegação inferior
                        const SizedBox(height: 80),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Extensão para capitalizar primeira letra
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
