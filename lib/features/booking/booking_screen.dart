// lib/features/booking/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:sevn_clinic_app/api/mock_api.dart';
import 'package:sevn_clinic_app/features/booking/confirmation_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final int? reschedulingAppointmentId;
  const BookingScreen({
    super.key, 
    required this.service, 
    this.reschedulingAppointmentId,});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final api = MockApi();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  Map<String, String>? _selectedSpecialist;

  Future<List<String>>? _slotsFuture;
  Future<List<Map<String, String>>>? _specialistsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _slotsFuture = api.getAvailableSlots(_selectedDay!);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedTimeSlot = null;
        _selectedSpecialist = null;
        _specialistsFuture = null;
        _slotsFuture = api.getAvailableSlots(selectedDay);
      });
    }
  }

  void _onTimeSlotSelected(String slot) {
    setState(() {
      _selectedTimeSlot = slot;
      _selectedSpecialist = null;
      _specialistsFuture = api.getAvailableSpecialists(
        service: widget.service,
        day: _selectedDay!,
        timeSlot: slot,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBookingReady = _selectedTimeSlot != null && _selectedSpecialist != null;

    return Scaffold(
      appBar: AppBar(title: Text('Запись на "${widget.service['name']}"')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              locale: 'ru_RU',
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 60)),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.deepPurple.shade200, shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Выберите время:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            FutureBuilder<List<String>>(
              future: _slotsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Нет доступных слотов.'));
                
                return Wrap(
                  spacing: 8.0, runSpacing: 8.0,
                  children: snapshot.data!.map((slot) {
                    final isSelected = _selectedTimeSlot == slot;
                    return ElevatedButton(
                      onPressed: () => _onTimeSlotSelected(slot),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[200],
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                      ),
                      child: Text(slot),
                    );
                  }).toList(),
                );
              },
            ),

            if (_selectedTimeSlot != null) ...[
              const SizedBox(height: 24),
              const Text('Выберите специалиста:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, String>>>(
                future: _specialistsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Нет доступных специалистов.'));
                  
                  return SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final specialist = snapshot.data![index];
                        final isSelected = _selectedSpecialist?['name'] == specialist['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSpecialist = specialist),
                          child: Card(
                            color: isSelected ? Colors.deepPurple.shade50 : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300, width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                      const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30),),
                                      const SizedBox(width: 12),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(specialist['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(specialist['title']!, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                onPressed: isBookingReady ? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ConfirmationScreen(
                        service: widget.service,
                        selectedDay: _selectedDay!,
                        selectedTimeSlot: _selectedTimeSlot!,
                        selectedSpecialist: _selectedSpecialist!,
                        reschedulingAppointmentId: widget.reschedulingAppointmentId,
                      ),
                    ),
                  );
                } : null,
                child: const Text('Подтвердить запись'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}