// lib/services/cart_service.dart

import 'package:flutter/foundation.dart';

class CartItem {
  final Map<String, dynamic> item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});
}

class CartService extends ChangeNotifier {
  factory CartService() { return _instance; }
  CartService._internal();
  static final CartService _instance = CartService._internal();

  final List<CartItem> _products = [];
  final List<CartItem> _services = [];

  List<CartItem> get products => _products;
  List<CartItem> get services => _services;

  int get totalItems {
    int total = 0;
    for (var cartItem in _products) { total += cartItem.quantity; }
    for (var cartItem in _services) { total += cartItem.quantity; }
    return total;
  }

  double get totalProductsPrice {
    return _products.fold(0.0, (sum, cartItem) => sum + (_parsePrice(cartItem.item['price']) * cartItem.quantity));
  }
  
  double get totalServicesPrice {
    return _services.fold(0.0, (sum, cartItem) => sum + (_parsePrice(cartItem.item['price']) * cartItem.quantity));
  }

  double get grandTotal => totalProductsPrice + totalServicesPrice;

  void addProduct(Map<String, dynamic> product) {
    final existingIndex = _products.indexWhere((cartItem) => cartItem.item['id'] == product['id']);
    if (existingIndex != -1) {
      _products[existingIndex].quantity++;
    } else {
      _products.add(CartItem(item: product));
    }
    notifyListeners();
  }

  void removeProduct(Map<String, dynamic> product) {
    final existingIndex = _products.indexWhere((cartItem) => cartItem.item['id'] == product['id']);
    if (existingIndex != -1) {
      if (_products[existingIndex].quantity > 1) {
        _products[existingIndex].quantity--;
      } else {
        _products.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void addService(Map<String, dynamic> service) {
    final existingIndex = _services.indexWhere((cartItem) => cartItem.item['name'] == service['name']);
    if (existingIndex != -1) {
      _services[existingIndex].quantity++;
    } else {
      _services.add(CartItem(item: service));
    }
    notifyListeners();
  }

  void removeService(Map<String, dynamic> service) {
     final existingIndex = _services.indexWhere((cartItem) => cartItem.item['name'] == service['name']);
    if (existingIndex != -1) {
      if (_services[existingIndex].quantity > 1) {
        _services[existingIndex].quantity--;
      } else {
        _services.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  int getQuantity(Map<String, dynamic> item, {bool isService = false}) {
    final list = isService ? _services : _products;
    final key = isService ? 'name' : 'id';
    
    final existingIndex = list.indexWhere((cartItem) => cartItem.item[key] == item[key]);
    if (existingIndex != -1) {
      return list[existingIndex].quantity;
    }
    return 0;
  }
  
  void clearCart() {
    _products.clear();
    _services.clear();
    notifyListeners();
  }

  double _parsePrice(String? priceString) {
    if (priceString == null) return 0.0;
    try {
      final cleanedString = priceString.replaceAll(' тг', '').replaceAll(' ', '');
      return double.parse(cleanedString);
    } catch (e) {
      print('Ошибка парсинга цены: $e');
      return 0.0;
    }
  }
}