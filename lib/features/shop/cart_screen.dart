// lib/features/shop/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevn_clinic_app/services/cart_service.dart';
import 'package:sevn_clinic_app/widgets/quantity_selector.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final NumberFormat _priceFormat = NumberFormat("#,##0", "ru_RU");

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

  void _onCartChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Корзина (${_cartService.totalItems})'),
        automaticallyImplyLeading: false,
      ),
      body: _cartService.totalItems == 0
          ? const Center(child: Text('Ваша корзина пуста.'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      if (_cartService.services.isNotEmpty)
                        _buildSection(
                          title: 'Услуги',
                          items: _cartService.services,
                        ),
                      if (_cartService.products.isNotEmpty)
                        _buildSection(
                          title: 'Товары',
                          items: _cartService.products,
                        ),
                    ],
                  ),
                ),
                _buildTotals(),
              ],
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<CartItem> items,
  }) {
    final bool isService = title == 'Услуги';
    final double subtotal = isService ? _cartService.totalServicesPrice : _cartService.totalProductsPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final cartItem = items[index];
            final item = cartItem.item;
            return ListTile(
              title: Text(item['name']),
              subtitle: Text(item['price']),
              trailing: QuantitySelector(
                quantity: cartItem.quantity,
                onIncrement: () => isService ? _cartService.addService(item) : _cartService.addProduct(item),
                onDecrement: () => isService ? _cartService.removeService(item) : _cartService.removeProduct(item),
              ),
            );
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Сумма по "$title"'),
              Text('${_priceFormat.format(subtotal)} тг', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTotals() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Общая сумма:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '${_priceFormat.format(_cartService.grandTotal)} тг',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Переход к оплате (в разработке)')),
                );
              },
              child: const Text('Перейти к оформлению'),
            ),
          ),
        ],
      ),
    );
  }
}