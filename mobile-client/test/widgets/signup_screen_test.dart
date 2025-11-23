// test/widgets/signup_screen_test.dart
// Tests widget pour l'écran d'inscription

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/features/auth/signup_screen.dart';
import 'package:namer_app/providers/auth_provider.dart';

void main() {
  group('SignupScreen Widget Tests', () {
    testWidgets('should display signup form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const SignupScreen(),
          ),
        ),
      );

      // Vérifier que tous les champs sont présents
      expect(find.text('Créez votre compte'), findsOneWidget);
      expect(find.text('Nom'), findsOneWidget);
      expect(find.text('Adresse e-mail'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('S\'inscrire'), findsOneWidget);
    });

    testWidgets('should validate all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const SignupScreen(),
          ),
        ),
      );

      // Essayer de soumettre sans remplir les champs
      final signupButton = find.text('S\'inscrire');
      await tester.tap(signupButton);
      await tester.pump();

      // Vérifier que les messages de validation apparaissent
      expect(find.text('Veuillez entrer votre nom'), findsOneWidget);
    });
  });
}

