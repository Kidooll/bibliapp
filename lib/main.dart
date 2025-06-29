import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'providers/app_providers.dart';
import 'styles/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/explorar/explorar_page.dart';
import 'pages/biblia/book_list_page.dart';
import 'pages/oracoes_page.dart';
import 'notePage.dart';
import 'widgets/auth_check.dart';
import 'services/auth_service.dart';
import 'providers/biblia_provider.dart';
import 'services/study_service.dart';
import 'services/user_progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializa o Supabase
    await Supabase.initialize(
      url: 'https://llcnxgrlvldvnhpsapdx.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsY254Z3Jsdmxkdm5ocHNhcGR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NzUyMzIsImV4cCI6MjA2MzQ1MTIzMn0.SmQ17LcUGX695I8h1yLYT853ic2QwNvneYm_XubbTLk',
    );
    debugPrint('Supabase inicializado com sucesso');
  } catch (e) {
    debugPrint('Erro ao inicializar serviços: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProgressService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BibliaProvider()),
        ChangeNotifierProvider(create: (_) => StudyService()),
      ],
      child: MaterialApp(
        title: 'Bíblia Devocional',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF5E9EA0),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5E9EA0),
            primary: const Color(0xFF5E9EA0),
            secondary: const Color(0xFF2C3E50),
          ),
          useMaterial3: true,
        ),
        home: const AuthCheck(
          child: MainScreen(),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _pages = <Widget>[
    const HomePage(key: PageStorageKey('HomePage')),
    const ExplorarPage(key: PageStorageKey('ExplorarPage')),
    const BookListPage(key: PageStorageKey('BookListPage')),
    const OracoesPage(key: PageStorageKey('OracoesPage')),
    const NotePage(key: PageStorageKey('NotePage')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _pages[_selectedIndex]),
      bottomNavigationBar: MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final PageStorageBucket _bucket = PageStorageBucket();

  final List<Widget> _pages = [
    HomePage(),
    ExplorarPage(),
    BookListPage(),
    OracoesPage(),
    NotePage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            elevation: 0,
            iconSize: 24,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF1F4549),
            backgroundColor:
                Colors.white.withOpacity(0.9), // Fundo semi-transparente
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Hoje'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Explorar'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.auto_stories), label: 'Bíblia'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.self_improvement), label: 'Orações'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.edit_note), label: 'Diário'),
            ],
          ),
        ),
      ),
    );
  }
}
