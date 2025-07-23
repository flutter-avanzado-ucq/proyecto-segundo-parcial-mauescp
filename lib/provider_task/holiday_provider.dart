import 'package:flutter/material.dart';
import '../services/holidays_service.dart';

class HolidayProvider with ChangeNotifier {
  final _holidayService = HolidayService();
  List<Holiday>? _holidays;
  String? _error;

  List<Holiday>? get holidays => _holidays;
  String? get error => _error;

  Future<void> loadHolidays() async {
    try {
      print('Iniciando carga de días festivos...'); // Debug print
      final currentYear = DateTime.now().year;
      _holidays = await _holidayService.fetchHolidays(
        year: currentYear,
        countryCode: 'MX',
      );
      print('Días festivos cargados: ${_holidays?.length ?? 0}'); // Debug print
      if (_holidays != null) {
        for (var holiday in _holidays!) {
          print('Feriado: ${holiday.localName} - ${holiday.date}'); // Debug print
        }
      }
      _error = null;
    } catch (e) {
      print('Error cargando días festivos: $e'); // Debug print
      _error = e.toString();
      _holidays = null;
    }
    notifyListeners();
  }

  Holiday? getNextHoliday() {
    if (_holidays == null || _holidays!.isEmpty) return null;
    
    final now = DateTime.now();
    try {
      return _holidays!.firstWhere(
        (holiday) => holiday.date.isAfter(now),
        orElse: () => _holidays!.first,
      );
    } catch (e) {
      return null;
    }
  }

  bool isHoliday(DateTime date) {
    if (_holidays == null) return false;
    return _holidays!.any((holiday) => 
        holiday.date.year == date.year &&
        holiday.date.month == date.month &&
        holiday.date.day == date.day
    );
  }

  String? getHolidayName(DateTime date) {
    if (_holidays == null) return null;
    
    try {
    final holiday = _holidays!.firstWhere(
      (h) => 
        h.date.year == date.year &&
        h.date.month == date.month &&
        h.date.day == date.day,
    );
      return holiday.localName;
    } catch (e) {
      return null;
    }
  }
}
