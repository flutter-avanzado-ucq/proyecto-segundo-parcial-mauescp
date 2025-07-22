import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el sistema de notificaciones
  static Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    tz.initializeTimeZones();

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  /// Maneja la respuesta del usuario al tocar la notificación
  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      print('Payload: ${response.payload}');
    }
  }

  /// Solicita permisos para mostrar notificaciones (iOS y Android 13+)
  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      await Permission.notification.request();
    }

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Muestra una notificación inmediata
  static Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Notificaciones Instantáneas',
      channelDescription: 'Canal para notificaciones inmediatas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Programa una notificación para una fecha futura
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required int notificationId,
    String? payload,
  }) async {
    // Verifica si estás en Android 12+ (API 31+)
    if (Platform.isAndroid) {
      final sdkInt = int.tryParse(Platform.version.split(' ').first) ?? 0;
      if (sdkInt >= 31) {
        // Abre configuración para permitir alarmas exactas
        await openExactAlarmPermissionSettings();
        return; // Salimos para que el usuario pueda habilitarlo manualmente
      }
    }

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notificaciones Programadas',
      channelDescription: 'Canal para recordatorios de tareas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Cancela una notificación específica por ID
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Abre los ajustes de Android para permitir "Alarmas exactas"
  static Future<void> openExactAlarmPermissionSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    }
  }
}
