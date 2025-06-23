// lib/features/shop/shop_screen.dart

import 'package:flutter/material.dart';
import 'package:sevn_clinic_app/api/mock_api.dart';
import 'package:sevn_clinic_app/services/cart_service.dart';
import 'package:sevn_clinic_app/widgets/quantity_selector.dart'; // Импортируем наш счетчик

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final Future<List<Map<String, dynamic>>> _productsFuture = MockApi().getProducts();
  final CartService _cartService = CartService();

  // --- ДОБАВЛЯЕМ "СЛУШАТЕЛЯ" ДЛЯ АВТОМАТИЧЕСКОГО ОБНОВЛЕНИЯ ЭКРАНА ---
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
    // Просто вызываем setState, чтобы экран перерисовался с новыми данными из корзины
    setState(() {});
  }
  // --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин косметики'),
        // TODO: Добавить иконку профиля и корзины
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Товаров пока нет.'));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7, // Адаптируем соотношение сторон
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              // Получаем количество этого товара в корзине
              final quantityInCart = _cartService.getQuantity(product, isService: false);

              return Card(
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Image.network(
                        product['image'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) => progress == null 
                            ? child 
                            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product['price'],
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- ИСПРАВЛЕННАЯ ЛОГИКА ДЛЯ КНОПКИ/СЧЕТЧИКА ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: quantityInCart > 0
                            // Если товар уже в корзине, показываем счетчик
                            ? QuantitySelector(
                                quantity: quantityInCart,
                                onIncrement: () => _cartService.addProduct(product),
                                onDecrement: () => _cartService.removeProduct(product),
                              )
                            // Иначе, показываем кнопку "В корзину"
                            : OutlinedButton.icon(
                                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                                label: const Text('В корзину', style: TextStyle(fontSize: 12)),
                                onPressed: () {
                                  _cartService.addProduct(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('"${product['name']}" добавлен в корзину'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}