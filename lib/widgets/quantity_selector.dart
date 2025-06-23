// lib/widgets/quantity_selector.dart

import 'package:flutter/material.dart';

/// Виджет-счетчик для управления количеством (-/число/+)
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36, // Фиксированная высота для единообразия
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка "минус"
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: onDecrement,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
          ),
          // Разделитель
          Container(
            width: 1,
            color: Colors.grey.shade300,
          ),
          // Текст с количеством
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Разделитель
          Container(
            width: 1,
            color: Colors.grey.shade300,
          ),
          // Кнопка "плюс"
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: onIncrement,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}