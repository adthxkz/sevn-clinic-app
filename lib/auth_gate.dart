// lib/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sevn_clinic_app/features/auth/login_screen.dart';
import 'package:sevn_clinic_app/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder слушает изменения состояния аутентификации в реальном времени
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Если пользователь еще не вошел, показываем экран входа
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Если пользователь вошел, показываем главный экран
        return const MainScreen();
      },
    );
  }
}