
import 'package:supabase_flutter/supabase_flutter.dart';


class AppConfig {
  static Future<void> initializeServices() async {
    // Inicializa o Supabase
    await Supabase.initialize(
      url: 'https://llcnxgrlvldvnhpsapdx.supabase.co', 
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsY254Z3Jsdmxkdm5ocHNhcGR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc4NzUyMzIsImV4cCI6MjA2MzQ1MTIzMn0.SmQ17LcUGX695I8h1yLYT853ic2QwNvneYm_XubbTLk',
    );
  }
}
