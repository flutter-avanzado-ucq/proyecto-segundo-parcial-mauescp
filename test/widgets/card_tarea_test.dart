import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import '../../lib/widgets/card_tarea.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/language_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';
import '../../lib/utils/translations.dart';
import 'package:intl/intl.dart';

// 👇 Importa el archivo generado automáticamente
import 'card_tarea_test.mocks.dart';

// 👇 Solo usamos customMocks para evitar conflictos con MockTranslations
@GenerateNiceMocks([
  MockSpec<LanguageProvider>(as: #MockLanguageProvider),
  MockSpec<HolidayProvider>(as: #MockHolidayProvider),
])

void main() {
  late MockLanguageProvider mockLanguageProvider;
  late MockHolidayProvider mockHolidayProvider;

  setUp(() {
    mockHolidayProvider = MockHolidayProvider();
    mockLanguageProvider = MockLanguageProvider();
  });

  Widget createTestWidget({
    required String title,
    required bool isDone,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
    required Animation<double> iconRotation,
    required int index,
    DateTime? dueDate,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>.value(
          value: mockLanguageProvider,
        ),
        ChangeNotifierProvider<HolidayProvider>.value(
          value: mockHolidayProvider,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TaskCard(
            title: title,
            isDone: isDone,
            onToggle: onToggle,
            onDelete: onDelete,
            iconRotation: iconRotation,
            index: index,
            dueDate: dueDate,
          ),
        ),
      ),
    );
  }

  group('Pruebas del Widget TaskCard', () {
    testWidgets('Debe renderizar el título y estado correctamente',
        (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        createTestWidget(
          title: 'Tarea de Prueba',
          isDone: false,
          onToggle: () {},
          onDelete: () {},
          iconRotation: controller,
          index: 0,
        ),
      );

      expect(find.text('Tarea de Prueba'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('Debe mostrar la fecha cuando se proporciona',
        (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );
      final dueDate = DateTime(2025, 7, 29, 14, 30);

      // Configurar el mock para las traducciones
      when(mockLanguageProvider.getTranslation('due')).thenReturn('Fecha límite');
      when(mockLanguageProvider.getTranslation('time')).thenReturn('Hora');

      await tester.pumpWidget(
        createTestWidget(
          title: 'Tarea con Fecha',
          isDone: false,
          onToggle: () {},
          onDelete: () {},
          iconRotation: controller,
          index: 0,
          dueDate: dueDate,
        ),
      );

      final lang = Provider.of<LanguageProvider>(tester.element(find.byType(TaskCard)), listen: false);
      final dueLabel = lang.getTranslation('due');
      final timeLabel = lang.getTranslation('time');

      expect(find.text('$dueLabel: ${DateFormat('dd/MM/yyyy').format(dueDate)}'), findsOneWidget);
      expect(find.text('$timeLabel: 14:30'), findsOneWidget);
    });

    testWidgets('Debe llamar a onToggle cuando se toca el checkbox',
        (WidgetTester tester) async {
      bool fueToggleado = false;
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        createTestWidget(
          title: 'Tarea Toggle',
          isDone: false,
          onToggle: () => fueToggleado = true,
          onDelete: () {},
          iconRotation: controller,
          index: 0,
        ),
      );

      await tester.tap(find.byIcon(Icons.radio_button_unchecked));
      expect(fueToggleado, true);
    });

    testWidgets('Debe llamar a onDelete cuando se toca el botón de eliminar',
        (WidgetTester tester) async {
      bool fueBorrado = false;
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        createTestWidget(
          title: 'Tarea para Borrar',
          isDone: false,
          onToggle: () {},
          onDelete: () => fueBorrado = true,
          iconRotation: controller,
          index: 0,
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(fueBorrado, true);
    });

    testWidgets('Debe mostrar el estado completado correctamente',
        (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );

      await tester.pumpWidget(
        createTestWidget(
          title: 'Tarea Completada',
          isDone: true,
          onToggle: () {},
          onDelete: () {},
          iconRotation: controller,
          index: 0,
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      final titleWidget = tester.widget<Text>(find.text('Tarea Completada'));
      expect(titleWidget.style?.decoration, equals(TextDecoration.lineThrough));
    });

    testWidgets('Debe mostrar información de día festivo',
        (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );
      final holidayDate = DateTime(2025, 12, 25);

      // Configurar el mock del HolidayProvider
      when(mockHolidayProvider.isHoliday(holidayDate)).thenReturn(true);
      when(mockHolidayProvider.getHolidayName(holidayDate)).thenReturn('Navidad');

      await tester.pumpWidget(
        createTestWidget(
          title: 'Tarea en Día Festivo',
          isDone: false,
          onToggle: () {},
          onDelete: () {},
          iconRotation: controller,
          index: 0,
          dueDate: holidayDate,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.celebration), findsOneWidget);
      expect(find.text('Navidad'), findsOneWidget);
    });

    testWidgets('Debe mostrar las traducciones correctamente',
        (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );
      final dueDate = DateTime(2025, 7, 29, 14, 30);

      // Configurar el mock para las traducciones
      when(mockLanguageProvider.getTranslation('due')).thenReturn('Fecha límite');
      when(mockLanguageProvider.getTranslation('time')).thenReturn('Hora');

      await tester.pumpWidget(
        createTestWidget(
          title: 'Tarea con Traducciones',
          isDone: false,
          onToggle: () {},
          onDelete: () {},
          iconRotation: controller,
          index: 0,
          dueDate: dueDate,
        ),
      );

      final textWidgets = find.byType(Text);
      for (var widget in tester.widgetList(textWidgets)) {
        print((widget as Text).data);
      }

      expect(find.text('Fecha límite: ${DateFormat('dd/MM/yyyy').format(dueDate)}'), findsOneWidget);
      expect(find.text('Hora: 14:30'), findsOneWidget);
    });

    testWidgets('Debe mostrar el nombre del día festivo si corresponde',
        (WidgetTester tester) async {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: const TestVSync(),
      );
      final dueDate = DateTime(2025, 12, 25);

      // Configurar el mock del HolidayProvider
      when(mockHolidayProvider.isHoliday(dueDate)).thenReturn(true);
      when(mockHolidayProvider.getHolidayName(dueDate)).thenReturn('Navidad');

      await tester.pumpWidget(
        createTestWidget(
          title: 'Tarea en Día Festivo',
          isDone: false,
          onToggle: () {},
          onDelete: () {},
          iconRotation: controller,
          index: 0,
          dueDate: dueDate,
        ),
      );

      expect(find.text('Navidad'), findsOneWidget);
    });
  });
}

// Helper class para las animaciones en tests
class TestVSync implements TickerProvider {
  const TestVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
