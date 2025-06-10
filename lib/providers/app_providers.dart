import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'biblia_provider.dart';
import '../services/auth_service.dart';

class AppProviders {
  static final List<ChangeNotifierProvider> providers = [
    ChangeNotifierProvider(create: (_) => BibliaProvider()),
    ChangeNotifierProvider(create: (_) => AuthService()),
  ];
}
