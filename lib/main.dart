import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/tarea_screen.dart';
import 'tema/tema_app.dart';
import 'package:provider/provider.dart';
import 'provider_task/task_provider.dart';
import 'provider_task/theme_provider.dart';
import 'provider_task/language_provider.dart';
import 'provider_task/holiday_provider.dart';
import 'models/task_model.dart';
import 'services/notification_service.dart';
import 'utils/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasksBox');
  await NotificationService.initializeNotifications();
  await NotificationService.requestPermission();
  await Translations.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()..initializeLanguage()),
        ChangeNotifierProvider(create: (_) => HolidayProvider()..loadHolidays()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Translations.get('appTitle'),
          theme: AppTheme.theme,
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const TaskScreen(),
        );
      },
    );
  }
}
