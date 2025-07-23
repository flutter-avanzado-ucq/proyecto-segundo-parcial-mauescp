import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'aaa4611c80764e794a7130271c37ca38'; 
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Map<String, dynamic>> getWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=es')
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener el clima');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}