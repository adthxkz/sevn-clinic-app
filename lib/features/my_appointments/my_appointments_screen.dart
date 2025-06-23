// lib/features/my_appointments/my_appointments_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevn_clinic_app/api/mock_api.dart';
import 'package:sevn_clinic_app/features/profile/profile_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  Future<List<Map<String, dynamic>>>? _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    setState(() {
       _appointmentsFuture = MockApi().getMyAppointments();
    });
  }

  Future<void> _showCancelDialog(int appointmentId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Отмена записи'),
          content: const SingleChildScrollView(child: Text('Вы уверены, что хотите отменить эту запись?')),
          actions: <Widget>[
            TextButton(
              child: const Text('Нет'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Да, отменить'),
              onPressed: () async {
                await MockApi().cancelAppointment(appointmentId);
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadAppointments();
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
      appBar: AppBar(title: const Text('Мои записи'),
      actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Переход на экран профиля
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return const Center(child: Text('Ошибка загрузки записей.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('У вас пока нет записей.'));
          }

          final allAppointments = snapshot.data!;
          final upcoming = allAppointments.where((a) => (a['dateTime'] as DateTime).isAfter(DateTime.now())).toList();
          final past = allAppointments.where((a) => (a['dateTime'] as DateTime).isBefore(DateTime.now())).toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(tabs: [Tab(text: 'ПРЕДСТОЯЩИЕ'), Tab(text: 'ПРОШЕДШИЕ')]),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAppointmentsList(upcoming, canCancel: true),
                      _buildAppointmentsList(past, canCancel: false),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments, {required bool canCancel}) {
    if (appointments.isEmpty) {
      return const Center(child: Text('Здесь пока пусто.'));
    }
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final service = appointment['service'] as Map<String, dynamic>;
        final formattedDate = DateFormat('d MMMM y, HH:mm', 'ru').format(appointment['dateTime']);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(service['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Мастер: ${appointment['specialistName']}\n$formattedDate'),
            isThreeLine: true,
            trailing: canCancel 
              ? IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () {
                    _showCancelDialog(appointment['id']);
                  },
                ) 
              : null,
          ),
        );
      },
    );
  }
}