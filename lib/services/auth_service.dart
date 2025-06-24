// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Получаем экземпляр Firebase Auth, через который будут идти все запросы
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Метод для регистрации нового пользователя
  /// Возвращает null в случае успеха или строку с ошибкой в случае неудачи.
  Future<String?> signUp({required String email, required String password}) async {
    try {
      // Используем стандартный метод Firebase для создания пользователя
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Если метод выше выполнился без ошибок, значит все хорошо.
      print('Пользователь успешно зарегистрирован: $email');
      return null; // Возвращаем null как признак успеха
    } on FirebaseAuthException catch (e) {
      // Перехватываем специальные ошибки от Firebase
      print('Ошибка регистрации Firebase: ${e.message}');
      if (e.code == 'weak-password') {
        return 'Предоставленный пароль слишком слабый.';
      } else if (e.code == 'email-already-in-use') {
        return 'Аккаунт для этого email уже существует.';
      }
      return e.message; // Возвращаем текст ошибки
    } catch (e) {
      // Перехватываем любые другие ошибки
      print('Общая ошибка регистрации: $e');
      return 'Произошла неизвестная ошибка.';
    }
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Пользователь успешно вошел: $email');
      return null;
    } on FirebaseAuthException catch (e) {
      print('Ошибка входа Firebase: ${e.message}');
      // Возвращаем более понятные сообщения для пользователя
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Неправильный email или пароль.';
      }
      return 'Произошла ошибка входа.';
    } catch (e) {
      print('Общая ошибка входа: $e');
      return 'Произошла неизвестная ошибка.';
    }
  }

  /// Метод для выхода пользователя из системы.
  Future<void> signOut() async {
    await _auth.signOut();
    print('Пользователь вышел из системы.');
  }
}