import 'package:flutter/material.dart';
// Integración Hive: importación de Hive Flutter
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/tarea_screen.dart';
import 'tema/tema_app.dart';
import 'package:provider/provider.dart';
import 'provider_task/task_provider.dart';

// Importar modelo para Hive
import 'models/task_model.dart';

// Importar el servicio de notificaciones
import 'services/notification_service.dart';

void main() async {
  // Asegura que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Integración Hive: inicialización de Hive
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>('tasksBox');

    // Inicializar notificaciones
    await NotificationService.initializeNotifications();
    await NotificationService.requestPermission();
    await NotificationService.requestExactAlarmPermission();
  } catch (e) {
    print('Error durante la inicialización: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tareas Pro',
      theme: AppTheme.theme,
      home: const TaskScreen(),
    );
  }
}
