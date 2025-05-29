import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notePage.dart'; // Certifique-se de que DiarioPage está aqui
import 'providers/biblia_provider.dart';
import 'pages/biblia/book_list_page.dart';
import 'pages/home_page.dart';
import 'pages/explorar/explorar_page.dart';
import 'pages/oracoes_page.dart';
import 'services/firestore_service.dart';
import 'styles/styles.dart';
import 'pages/login/login_controller.dart';
import 'services/auth_service.dart';
import 'widgets/auth_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa o Supabase
  await Supabase.initialize(
    url: 'https://llcnxgrlvldvnhpsapdx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsY254Z3Jsdmxkdm5ocHNhcGR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NzUyMzIsImV4cCI6MjA2MzQ1MTIzMn0.SmQ17LcUGX695I8h1yLYT853ic2QwNvneYm_XubbTLk',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BibliaProvider()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const DevocionalApp(),
    ),
  );
}

class DevocionalApp extends StatelessWidget {
  const DevocionalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoração Diária',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFf1fffd),
        fontFamily: 'Merriweather',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const AuthCheck(
        child: MainNavigation(),
      ),
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
    DiarioPage(),
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
