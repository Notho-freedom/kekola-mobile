// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/auth_provider.dart';
import 'services/firebase_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase (optionnel - fonctionne même si non configuré)
  await FirebaseInit.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const CommercantApp(),
    ),
  );
}
