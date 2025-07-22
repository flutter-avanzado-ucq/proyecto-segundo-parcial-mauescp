import 'package:flutter/material.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/language_provider.dart';
import 'package:flutter_animaciones_notificaciones/utils/translations.dart';
import 'package:flutter_animaciones_notificaciones/services/weather_service.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Map<String, dynamic>? _weatherData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await WeatherService.getWeather('Mexico City'); // Puedes cambiar la ciudad
      setState(() {
        _weatherData = weather;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _weatherData = null;
      });
    }
  }

  Widget _buildWeatherInfo() {
    if (_error != null) {
      return Text(
        Translations.get('weather_error'),
        style: const TextStyle(color: Colors.white70),
      );
    }

    if (_weatherData == null) {
      return Text(
        Translations.get('loading_weather'),
        style: const TextStyle(color: Colors.white70),
      );
    }

    final temp = _weatherData!['main']['temp'].round().toString();
    final description = _weatherData!['weather'][0]['description'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Translations.get('temperature', {'temp': temp}),
          style: const TextStyle(color: Colors.white70),
        ),
        Text(
          Translations.get('weather_description', {'description': description}),
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translations.get('welcome_message', {'user': 'MAU'}),
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        Translations.get('tasks_today'),
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildWeatherInfo(),
            ],
          ),
        );
      },
    );
  }
}