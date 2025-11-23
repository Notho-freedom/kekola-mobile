// test/widgets/login_screen_test.dart
// Tests widget pour l'écran de connexion

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/features/auth/login_screen.dart';
import 'package:namer_app/providers/auth_provider.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display login form', (WidgetTester tester) async {
      // Créer l'application avec Provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Vérifier que les champs sont présents
      expect(find.text('Bienvenue !'), findsOneWidget);
      expect(find.text('Adresse e-mail'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('Pas de compte ? Inscrivez-vous'), findsOneWidget);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Trouver le champ email et entrer une valeur invalide
      final emailField = find.widgetWithText(TextFormField, '');
      await tester.enterText(emailField.first, 'invalid-email');
      
      // Trouver le bouton de connexion et cliquer
      final loginButton = find.text('Se connecter');
      await tester.tap(loginButton);
      await tester.pump();

      // Vérifier qu'un message d'erreur apparaît
      expect(find.text('E-mail invalide'), findsOneWidget);
    });

    testWidgets('should validate password field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Entrer un mot de passe trop court
      final passwordFields = find.byType(TextFormField);
      await tester.enterText(passwordFields.last, '123');
      
      final loginButton = find.text('Se connecter');
      await tester.tap(loginButton);
      await tester.pump();

      // Vérifier le message d'erreur
      expect(find.text('Le mot de passe doit contenir au moins 6 caractères'), findsOneWidget);
    });
  });
}

