import 'dart:convert';
import 'package:http/http.dart' as http;

/// Modelo que representa un feriado público
class Holiday {
  final String localName;
  final DateTime date;

  Holiday({
    required this.localName,
    required this.date, required String name, required String countryCode,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      localName: json['localName'],
      date: DateTime.parse(json['date']), name: '', countryCode: '',
    );
  }
}

/// Servicio para obtener feriados públicos desde la API de Nager.Date
class HolidayService {
  static const String _baseUrl = 'https://date.nager.at/api/v3';

  /// Obtiene todos los feriados públicos del año para el país dado
  Future<List<Holiday>> fetchHolidays({
    required int year,
    required String countryCode,
  }) async {
    final url = Uri.parse('$_baseUrl/PublicHolidays/$year/$countryCode');
    final response = await http.get(url);
    
      if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((item) => Holiday.fromJson(item)).toList();
      } else {
      throw Exception('Error al obtener los días feriados');
      }
    }
  }
