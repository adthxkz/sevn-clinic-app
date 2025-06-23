// lib/features/services/services_screen.dart

import 'package:flutter/material.dart';
import 'package:sevn_clinic_app/api/mock_api.dart';
import 'package:sevn_clinic_app/features/booking/booking_screen.dart';
import 'package:sevn_clinic_app/features/profile/profile_screen.dart';
import 'package:sevn_clinic_app/services/cart_service.dart';
import 'package:sevn_clinic_app/widgets/quantity_selector.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final CartService _cartService = CartService();
  // Теперь мы загружаем и услуги, и профиль, чтобы сравнить их
  late Future<List<dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    // Загружаем все данные одним запросом
    _dataFuture = Future.wait([
      MockApi().getServices(),
      MockApi().getProfileData(),
    ]);
    _cartService.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Услуги и цены'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных.'));
          }

          final categories = snapshot.data![0] as List<Map<String, dynamic>>;
          final profileData = snapshot.data![1] as Map<String, dynamic>;
          final membershipServices = (profileData['membership']?['services'] as List?) ?? [];

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final services = category['services'] as List;

              return ExpansionTile(
                title: Text(category['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                children: services.map((service) {
                  final quantityInCart = _cartService.getQuantity(service, isService: true);
                  final isServiceInMembership = membershipServices.any((s) => s['name'] == service['name'] && s['left'] > 0);

                  return ListTile(
                    title: Text(service['name']),
                    subtitle: Text('${service['duration']}, ${service['price']}'),
                    trailing: isServiceInMembership
                        ? ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BookingScreen(service: service as Map<String, dynamic>),
                              ));
                            },
                            child: const Text('Записаться'),
                          )
                        : quantityInCart > 0
                            ? QuantitySelector(
                                quantity: quantityInCart,
                                onIncrement: () => _cartService.addService(service),
                                onDecrement: () => _cartService.removeService(service),
                              )
                            : OutlinedButton(
                                onPressed: () => _cartService.addService(service),
                                child: const Text('В корзину'),
                              ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}