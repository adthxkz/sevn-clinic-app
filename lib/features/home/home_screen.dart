// lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevn_clinic_app/api/mock_api.dart';
import 'package:sevn_clinic_app/features/booking/booking_screen.dart';
import 'package:sevn_clinic_app/features/profile/profile_screen.dart';
import 'package:sevn_clinic_app/services/cart_service.dart';
import 'package:sevn_clinic_app/widgets/global_cart_icon.dart';
import 'package:sevn_clinic_app/widgets/quantity_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Map<String, dynamic>?>? _upcomingAppointmentFuture;
  Future<Map<String, dynamic>>? _profileFuture;
  final CartService _cartService = CartService();

  final List<Map<String, String>> popularServices = [
    {'name': 'Классический массаж лица', 'image': 'https://picsum.photos/seed/massage/200/300', 'price': '18 000 тг', 'duration': '60 мин'},
    {'name': 'Пилинг', 'image': 'https://picsum.photos/seed/piling/200/300', 'price': '15 000 тг', 'duration': '40 мин'},
    {'name': 'Комбинированная чистка', 'image': 'https://picsum.photos/seed/cleaning/200/300', 'price': '20 000 тг', 'duration': '90 мин'},
  ];

  final List<Map<String, String>> newProducts = [
    {'id': '101', 'name': 'Крем "Сияние"', 'image': 'https://picsum.photos/seed/cream1/200/300', 'price': '15 000 тг'},
    {'id': '102', 'name': 'Сыворотка "Лифтинг"', 'image': 'https://picsum.photos/seed/serum1/200/300', 'price': '25 000 тг'},
    {'id': '103', 'name': 'Маска "Увлажнение"', 'image': 'https://picsum.photos/seed/mask1/200/300', 'price': '12 000 тг'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() {
    if (mounted) {
      setState(() {
        _upcomingAppointmentFuture = MockApi().getUpcomingAppointment();
        _profileFuture = MockApi().getProfileData();
      });
    }
  }

  Future<void> _showCancelDialog(int appointmentId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Отмена записи'),
          content: const Text('Вы уверены, что хотите отменить эту запись?'),
          actions: <Widget>[
            TextButton(child: const Text('Нет'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Да, отменить'),
              onPressed: () async {
                await MockApi().cancelAppointment(appointmentId);
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadData();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: _upcomingAppointmentFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return const SizedBox(height: 150, child: Center(child: Text('У вас нет предстоящих записей.', style: TextStyle(fontSize: 16, color: Colors.grey))));
                    }
                    
                    final appointment = snapshot.data!;
                    final service = appointment['service'] as Map<String, dynamic>;
                    final DateTime dateTime = appointment['dateTime'];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ближайшая запись', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(service['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Row(children: [ const Icon(Icons.person_outline, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(appointment['specialistName']),]),
                                const SizedBox(height: 8),
                                Row(children: [ const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey), const SizedBox(width: 8), Text(DateFormat('d MMMM y, HH:mm', 'ru').format(dateTime)),]),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(onPressed: () => _showCancelDialog(appointment['id']), child: const Text('Отменить')),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => BookingScreen(
                                            service: service,
                                            reschedulingAppointmentId: appointment['id'],
                                          ),
                                        ));
                                      },
                                      child: const Text('Перенести')
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 230, child: Center(child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox(height: 230, child: Center(child: Text('Не удалось загрузить данные.')));
                  }

                  final profileData = snapshot.data!;
                  final membershipServices = (profileData['membership']?['services'] as List?) ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HorizontalListSection(
                        title: 'Популярные услуги',
                        items: popularServices,
                        isService: true,
                        membershipServices: membershipServices,
                        onBookPressed: (service) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookingScreen(service: service)));
                        },
                        onAddToCartPressed: (item) => _cartService.addService(item),
                        onIncrement: (item) => _cartService.addService(item),
                        onDecrement: (item) => _cartService.removeService(item),
                      ),
                      const SizedBox(height: 24),
                      _HorizontalListSection(
                        title: 'Новинки в магазине',
                        items: newProducts,
                        onAddToCartPressed: (item) => _cartService.addProduct(item),
                        onIncrement: (item) => _cartService.addProduct(item),
                        onDecrement: (item) => _cartService.removeProduct(item),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== ИСПРАВЛЕННЫЙ ВИДЖЕТ ГОРИЗОНТАЛЬНОГО СПИСКА =====
class _HorizontalListSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final bool isService;
  final List<dynamic> membershipServices;
  final Function(Map<String, String>)? onBookPressed;
  final Function(Map<String, String>) onAddToCartPressed;
  final Function(Map<String, String>) onIncrement;
  final Function(Map<String, String>) onDecrement;

  const _HorizontalListSection({
    required this.title,
    required this.items,
    this.isService = false,
    this.membershipServices = const [],
    this.onBookPressed,
    required this.onAddToCartPressed,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 235, // Увеличиваем общую высоту блока
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final quantityInCart = cartService.getQuantity(item, isService: isService);
              final isServiceInMembership = isService && membershipServices.any((s) => s['name'] == item['name'] && s['left'] > 0);

              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 16.0 : 8.0, right: index == items.length - 1 ? 16.0 : 0),
                child: SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                item['image']!,
                                height: 110,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(item['price']!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          height: 36,
                          child: isServiceInMembership
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                                  onPressed: () => onBookPressed?.call(item),
                                  child: const Text('Записаться', style: TextStyle(fontSize: 12)),
                                )
                              : quantityInCart > 0
                                  ? QuantitySelector(
                                      quantity: quantityInCart,
                                      onIncrement: () => onIncrement(item),
                                      onDecrement: () => onDecrement(item),
                                    )
                                  : OutlinedButton(
                                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                                      onPressed: () => onAddToCartPressed(item),
                                      child: const Text('В корзину', style: TextStyle(fontSize: 12)),
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}