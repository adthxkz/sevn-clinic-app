// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:sevn_clinic_app/features/home/home_screen.dart';
import 'package:sevn_clinic_app/features/my_appointments/my_appointments_screen.dart';
import 'package:sevn_clinic_app/features/profile/profile_screen.dart';
import 'package:sevn_clinic_app/features/services/services_screen.dart';
import 'package:sevn_clinic_app/features/shop/cart_screen.dart';
import 'package:sevn_clinic_app/features/shop/shop_screen.dart';
import 'package:sevn_clinic_app/services/cart_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final CartService _cartService = CartService();

  // Подписываемся на изменения в корзине, чтобы обновлять UI
  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  // Эта функция вызывает перерисовку экрана при изменении корзины
  void _onCartChanged() {
    setState(() {});
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ServicesScreen(),
    ShopScreen(),
    MyAppointmentsScreen(),
    CartScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ===== НОВЫЙ ВСПОМОГАТЕЛЬНЫЙ ВИДЖЕТ ДЛЯ ИКОНКИ С БЕЙДЖЕМ =====
  Widget _buildCartIcon() {
    final itemCount = _cartService.totalItems;

    return Stack(
      clipBehavior: Clip.none, // Позволяет бейджу выходить за границы иконки
      children: [
        const Icon(Icons.shopping_cart_outlined),
        // Показываем красный кружок, только если в корзине что-то есть
        if (itemCount > 0)
          Positioned(
            right: -5,
            top: -5,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
  // =============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Главная'),
          const BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Услуги'),
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Магазин'),
          const BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Мои записи'),
          // --- ИЗМЕНЕНИЕ ЗДЕСЬ: Используем наш новый виджет для иконки ---
          BottomNavigationBarItem(
            icon: _buildCartIcon(),
            label: 'Корзина',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}