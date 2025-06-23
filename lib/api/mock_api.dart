// lib/api/mock_api.dart

class MockApi {
  // --- Синглтон ---
  factory MockApi() { return _instance; }
  static final MockApi _instance = MockApi._internal();

  // --- "Живые" данные ---
  late final Map<String, Map<String, dynamic>> _usersData;
  String? _currentLoggedInUserEmail;

  // Приватный конструктор для инициализации данных
  MockApi._internal() {
    _usersData = {
      'client@demo.com': {
        'password': '123456',
        'profile': {
          'name': 'Анна',
          'phone': '+7 (707) 123-45-67',
          'email': 'client@demo.com',
          'loyalty': { 'points': 1250, 'promoCode': 'ANNA_FRIEND_25' },
          'membership': { 'name': 'Абонемент "Gold"', 'validUntil': '25.12.2025', 'services': [
            {'name': 'Классический массаж лица', 'total': 5, 'left': 3, 'price': '18 000 тг'},
            {'name': 'Пилинг', 'total': 3, 'left': 1, 'price': '15 000 тг'},
          ]}
        },
        'appointments': [
          {
            'id': 1,
            'service': {'name': 'Массаж лица', 'duration': '60 мин', 'price': '18 000 тг'}, 
            'specialistName': 'Мастер Елена',
            'dateTime': DateTime.now().add(const Duration(days: 3, hours: 5)),
          }
        ]
      }
    };
  }
  
  // --- Методы API ---

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? promoCode,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (_usersData.containsKey(email)) {
      return {'status': 'error', 'message': 'Пользователь с таким email уже существует.'};
    }

    final membershipTemplate = _usersData['client@demo.com']!['profile']!['membership'] as Map<String, dynamic>;
    final newMembership = {
      'name': membershipTemplate['name'],
      'validUntil': membershipTemplate['validUntil'],
      'services': (membershipTemplate['services'] as List).map<Map<String, dynamic>>((service) => Map<String, dynamic>.from(service)).toList(),
    };
    
    _usersData[email] = {
      'password': password,
      'profile': {
        'name': name, 'phone': '', 'email': email,
        'loyalty': { 'points': 0, 'promoCode': '${name.toUpperCase()}_FRIEND_NEW' },
        'membership': newMembership,
      },
      'appointments': []
    };
    
    _currentLoggedInUserEmail = email;
    return {'status': 'ok'};
  }
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final userData = _usersData[email];
    if (userData != null && userData['password'] == password) {
      _currentLoggedInUserEmail = email;
      return {'status': 'ok'};
    } else {
      return {'status': 'error', 'message': 'Неправильный email или пароль'};
    }
  }

  Future<Map<String, dynamic>> getProfileData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_currentLoggedInUserEmail == null) return {};
    return _usersData[_currentLoggedInUserEmail]!['profile'];
  }

  Future<bool> bookAppointment({
    required Map<String, dynamic> service,
    required DateTime day,
    required String timeSlot,
    required Map<String, String> specialist,
  }) async {
    if (_currentLoggedInUserEmail == null) return false;
    await Future.delayed(const Duration(seconds: 1));

    try {
      final profile = _usersData[_currentLoggedInUserEmail]!['profile'] as Map<String, dynamic>;
      final membershipData = profile['membership'] as Map<String, dynamic>?;
      if (membershipData != null) {
        final membershipServices = membershipData['services'] as List;
        final serviceInMembershipIndex = membershipServices.indexWhere((s) => s['name'] == service['name']);

        if (serviceInMembershipIndex != -1) {
          final serviceInMembership = membershipServices[serviceInMembershipIndex];
          if (serviceInMembership['left'] > 0) {
            serviceInMembership['left']--;
          }
        }
      }
    } catch (e) {
      print('Ошибка при списании из абонемента: $e');
    }
    
    final timeParts = timeSlot.split(':');
    final appointmentDateTime = DateTime(day.year, day.month, day.day, int.parse(timeParts[0]), int.parse(timeParts[1]));

    final newAppointment = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'service': service,
      'specialistName': specialist['name'], 
      'dateTime': appointmentDateTime,
    };
    (_usersData[_currentLoggedInUserEmail]!['appointments'] as List).add(newAppointment);
    return true;
  }
  
  Future<Map<String, dynamic>?> getUpcomingAppointment() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentLoggedInUserEmail == null) return null;
    final appointments = _usersData[_currentLoggedInUserEmail]!['appointments'] as List;
    final upcomingAppointments = appointments.where((a) => (a['dateTime'] as DateTime).isAfter(DateTime.now())).toList();
    if (upcomingAppointments.isEmpty) { return null; }
    upcomingAppointments.sort((a, b) => (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));
    return upcomingAppointments.first;
  }
  
  Future<bool> cancelAppointment(int appointmentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_currentLoggedInUserEmail == null) return false;
    final appointments = _usersData[_currentLoggedInUserEmail]!['appointments'] as List;
    appointments.removeWhere((appointment) => appointment['id'] == appointmentId);
    return true;
  }

  Future<List<Map<String, dynamic>>> getMyAppointments() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentLoggedInUserEmail == null) return [];
    final appointments = _usersData[_currentLoggedInUserEmail]!['appointments'] as List;
    appointments.sort((a, b) => (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime));
    return List.from(appointments);
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      {'category': 'Уход за лицом', 'services': [{'name': 'Комбинированная чистка', 'duration': '90 мин', 'price': '20 000 тг'}, {'name': 'Ультразвуковая чистка', 'duration': '60 мин', 'price': '15 000 тг'}, {'name': 'Альгинатная маска', 'duration': '40 мин', 'price': '10 000 тг'}]},
      {'category': 'Аппаратная косметология', 'services': [{'name': 'SMAS-лифтинг', 'duration': '60 мин', 'price': '100 000 тг'}, {'name': 'Фотоомоложение', 'duration': '40 мин', 'price': '35 000 тг'}, {'name': 'Лазерная шлифовка', 'duration': '90 мин', 'price': '70 000 тг'}]},
      {'category': 'Массаж', 'services': [{'name': 'Классический массаж лица', 'duration': '60 мин', 'price': '18 000 тг'}, {'name': 'Лимфодренажный массаж', 'duration': '60 мин', 'price': '18 000 тг'}]},
    ];
  }

  Future<List<String>> getAvailableSlots(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (date.day % 2 == 0) {
      return ['10:00', '11:30', '14:00', '15:30', '17:00'];
    } else {
      return ['09:30', '11:00', '13:30', '15:00', '16:30', '18:00'];
    }
  }

  Future<List<Map<String, String>>> getAvailableSpecialists({required Map<String, dynamic> service, required DateTime day, required String timeSlot}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (service['name'].toString().contains('Массаж')) {
      return [{'name': 'Елена Войцеховская', 'title': 'Косметолог-эстетист', 'image': 'https://i.pravatar.cc/150?img=1'}, {'name': 'Анна Петрова', 'title': 'Массажист', 'image': 'https://i.pravatar.cc/150?img=5'}];
    } else {
      return [{'name': 'Елена Войцеховская', 'title': 'Косметолог-эстетист', 'image': 'https://i.pravatar.cc/150?img=1'}, {'name': 'Мария Иванова', 'title': 'Дерматокосметолог', 'image': 'https://i.pravatar.cc/150?img=8'}, {'name': 'Светлана Сидорова', 'title': 'Врач-косметолог', 'image': 'https://i.pravatar.cc/150?img=10'}];
    }
  }
  Future<List<Map<String, dynamic>>> getProducts() async {
  await Future.delayed(const Duration(milliseconds: 700));
  return [
    {
      'id': 101,
      'name': 'Увлажняющий крем "AquaSource"',
      'price': '15 000 тг',
      'description': 'Интенсивно увлажняющий крем для всех типов кожи с гиалуроновой кислотой.',
      'image': 'https://picsum.photos/seed/cream_aqua/400/400'
    },
    {
      'id': 102,
      'name': 'Сыворотка "LiftActive"',
      'price': '25 000 тг',
      'description': 'Антивозрастная сыворотка с пептидным комплексом для повышения упругости кожи.',
      'image': 'https://picsum.photos/seed/serum_lift/400/400'
    },
    {
      'id': 103,
      'name': 'Очищающая пенка "PureGlow"',
      'price': '12 000 тг',
      'description': 'Нежная пенка для умывания, эффективно удаляет макияж и загрязнения.',
      'image': 'https://picsum.photos/seed/foam_pure/400/400'
    },
    {
      'id': 104,
      'name': 'Солнцезащитный флюид SPF 50+',
      'price': '18 000 тг',
      'description': 'Легкий флюид с максимальной защитой от UVA и UVB лучей.',
      'image': 'https://picsum.photos/seed/spf_fluid/400/400'
    },
  ];
  }
}