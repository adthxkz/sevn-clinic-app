// lib/features/booking/confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sevn_clinic_app/api/mock_api.dart';
import 'package:sevn_clinic_app/main_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final DateTime selectedDay;
  final String selectedTimeSlot;
  final Map<String, String> selectedSpecialist;
  final int? reschedulingAppointmentId;

  const ConfirmationScreen({
    super.key,
    required this.service,
    required this.selectedDay,
    required this.selectedTimeSlot,
    required this.selectedSpecialist,
    this.reschedulingAppointmentId,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  bool _isLoading = false;

  Future<void> _confirmBooking() async {
    setState(() { _isLoading = true; });

    // ===== ВОТ КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ =====
    // Если мы переносим запись (reschedulingAppointmentId не равен null),
    // то сначала отменяем старую запись по ее ID.
    if (widget.reschedulingAppointmentId != null) {
      await MockApi().cancelAppointment(widget.reschedulingAppointmentId!);
    }
    
    // После этого в любом случае создаем новую запись.
    final success = await MockApi().bookAppointment(
      service: widget.service,
      day: widget.selectedDay,
      timeSlot: widget.selectedTimeSlot,
      specialist: widget.selectedSpecialist,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.reschedulingAppointmentId != null ? 'Запись успешно перенесена!' : 'Вы успешно записаны!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось создать запись. Попробуйте снова.'), backgroundColor: Colors.red),
        );
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMMM y, EEEE', 'ru').format(widget.selectedDay);
    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение записи')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Пожалуйста, проверьте детали вашей записи:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.cut_outlined, 'Услуга', widget.service['name']),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(children: [
                const CircleAvatar(radius: 25, child: Icon(Icons.person, size: 25)),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Специалист', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(widget.selectedSpecialist['name']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              ]),
            ),
            const Divider(),
            _buildInfoRow(Icons.calendar_today_outlined, 'Дата', formattedDate),
            const Divider(),
            _buildInfoRow(Icons.access_time_outlined, 'Время', widget.selectedTimeSlot),
            const Divider(),
            _buildInfoRow(Icons.money_outlined, 'Стоимость', widget.service['price']),
            const Spacer(),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
                      onPressed: _confirmBooking,
                      child: const Text('Подтвердить и записаться'),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ]),
    );
  }
}