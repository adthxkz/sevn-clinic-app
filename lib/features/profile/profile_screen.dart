// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevn_clinic_app/api/mock_api.dart';
import 'package:sevn_clinic_app/services/cart_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Future<Map<String, dynamic>> _profileFuture = MockApi().getProfileData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой профиль'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Не удалось загрузить данные профиля.'));
          }

          final profileData = snapshot.data!;
          final membership = profileData['membership']; // Получаем данные абонемента
          final loyalty = profileData['loyalty'];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Блок с личными данными
              _buildSectionCard(
                title: 'Личные данные',
                children: [
                  ListTile(leading: const Icon(Icons.person_outline), title: Text(profileData['name'] ?? 'Имя не указано')),
                  ListTile(leading: const Icon(Icons.phone_outlined), title: Text(profileData['phone'] ?? '')),
                  ListTile(leading: const Icon(Icons.email_outlined), title: Text(profileData['email'] ?? 'Email не указан')),
                ],
              ),
              const SizedBox(height: 20),

              // ===== ИСПРАВЛЕНИЕ ЗДЕСЬ =====
              // Показываем блок с абонементом, только если он не null
              if (membership != null)
                _buildSectionCard(
                  title: 'Мой абонемент',
                  children: [
                    ListTile(
                      title: Text(membership['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('Действителен до: ${membership['validUntil']}'),
                    ),
                    const Divider(),
                    for (var service in membership['services'])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${service['name']}: осталось ${service['left']} из ${service['total']}', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: (service['left'] as int) / (service['total'] as int),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              
              const SizedBox(height: 20),

              // Блок с программой лояльности
              _buildSectionCard(
                title: 'Программа лояльности',
                children: [
                   ListTile(
                     leading: const Icon(Icons.star_outline, color: Colors.amber),
                     title: const Text('Бонусные баллы'),
                     trailing: Text('${loyalty['points']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                   ),
                   ListTile(
                     leading: const Icon(Icons.group_add_outlined),
                     title: const Text('Промокод "Пригласи друга"'),
                     subtitle: Text(loyalty['promoCode'], style: const TextStyle(fontWeight: FontWeight.bold)),
                   ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}