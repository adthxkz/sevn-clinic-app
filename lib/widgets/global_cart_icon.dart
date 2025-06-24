// lib/widgets/global_cart_icon.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevn_clinic_app/features/shop/cart_screen.dart';
import 'package:sevn_clinic_app/services/cart_service.dart';

class GlobalCartIcon extends StatelessWidget {
  const GlobalCartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CartScreen()));
          },
          borderRadius: BorderRadius.circular(50),
          child: Stack(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.shopping_cart_outlined),
              ),
              if (cartService.totalItems > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${cartService.totalItems}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}