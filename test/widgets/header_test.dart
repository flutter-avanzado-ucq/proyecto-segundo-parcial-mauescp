import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animaciones_notificaciones/services/holidays_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animaciones_notificaciones/widgets/header.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/language_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';
import 'package:flutter_animaciones_notificaciones/services/weather_service.dart';

// Importar el archivo generado de mocks
import 'header_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<LanguageProvider>(as: #MockLanguageProvider),
  MockSpec<HolidayProvider>(as: #MockHolidayProvider),
  MockSpec<WeatherService>(as: #MockWeatherService),
])
void main() {
  late MockLanguageProvider mockLanguageProvider;
  late MockHolidayProvider mockHolidayProvider;
  late MockWeatherService mockWeatherService;

  setUp(() {
    mockLanguageProvider = MockLanguageProvider();
    mockHolidayProvider = MockHolidayProvider();
    mockWeatherService = MockWeatherService();

    // Configurar comportamiento básico
    when(mockLanguageProvider.getTranslation('welcome_message'))
        .thenReturn('¡Hola, MAU!'); // Directamente sin {user}
    
    // Deshabilitar carga de imágenes de red
    HttpOverrides.global = null;
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>.value(
          value: mockLanguageProvider,
        ),
        ChangeNotifierProvider<HolidayProvider>.value(
          value: mockHolidayProvider,
        ),
        // 👇 Agrega el WeatherService si tu widget real lo necesita
        Provider<WeatherService>.value(
          value: mockWeatherService,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Header(), // 👈 Esta será la clase real
        ),
      ),
    );
  }

  group('Pruebas del Header', () {
    testWidgets('Debe mostrar el mensaje de bienvenida',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 👇 Agrega esto para ver qué textos hay realmente
      final textWidgets = find.byType(Text);
      print('Textos encontrados en pantalla:');
      for (var widget in tester.widgetList(textWidgets)) {
        print('- "${(widget as Text).data}"');
      }

      expect(find.text('¡Hola, MAU!'), findsOneWidget);
      expect(find.text('Tus tareas para hoy'), findsOneWidget);
    });

    testWidgets('Debe mostrar la información del clima cuando está cargando',
        (WidgetTester tester) async {
      when(mockLanguageProvider.getTranslation('loading_weather'))
          .thenReturn('Cargando clima...');

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Cargando clima...'), findsOneWidget);
    });

    testWidgets('Debe mostrar la información del clima cuando está disponible',
        (WidgetTester tester) async {
      when(mockLanguageProvider.getTranslation('temperature'))
          .thenReturn('Temperatura: {temp}°C');
      when(mockLanguageProvider.getTranslation('weather_description'))
          .thenReturn('Clima: {description}');

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Simular respuesta del servicio del clima
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.textContaining('Temperatura:'), findsOneWidget);
      expect(find.textContaining('Clima:'), findsOneWidget);
    });

    testWidgets('Debe mostrar información del próximo día festivo',
        (WidgetTester tester) async {
      final nextHoliday = DateTime(2025, 12, 25);
      when(mockHolidayProvider.getNextHoliday()).thenReturn(
        Holiday(
          date: nextHoliday,
          localName: 'Navidad',
          name: 'Christmas',
          countryCode: 'MX', // <-- Replace this line with the correct parameter name, e.g., code: 'MX',
        ),
      );

      when(mockLanguageProvider.getTranslation('next_holiday'))
          .thenReturn('Próximo feriado: {name} ({date})');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Próximo feriado: Navidad'), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje cuando no hay días festivos',
        (WidgetTester tester) async {
      when(mockHolidayProvider.getNextHoliday()).thenReturn(null);
      when(mockLanguageProvider.getTranslation('no_holidays'))
          .thenReturn('No hay próximos feriados');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No hay próximos feriados'), findsOneWidget);
    });
  });
}

class Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final welcomeMessage = languageProvider.getTranslation('welcome_message');
        
        return Column(
          children: [
            Text(welcomeMessage), // 👈 Esto debe mostrar "¡Hola, MAU!"
            // ... otros widgets
          ],
        );
      },
    );
  }
}