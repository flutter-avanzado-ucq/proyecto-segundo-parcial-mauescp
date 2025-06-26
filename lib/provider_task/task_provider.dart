import 'package:flutter/material.dart';
// Integración Hive: importación de Hive
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  // Integración Hive: acceso a la caja tasksBox
  Box<Task> get _taskBox => Hive.box<Task>('tasksBox');

  // Integración Hive: obtención de tareas desde Hive
  List<Task> get tasks => _taskBox.values.toList();

  void addTask(String title, {DateTime? dueDate, TimeOfDay? dueTime, int? notificationId}) async {
    // Integración Hive: creación y almacenamiento de tarea en Hive
    final task = Task(
      title: title,
      dueDate: dueDate,
      notificationId: notificationId,
    );

    await _taskBox.add(task);
    notifyListeners();
  }

  void toggleTask(int index) async {
    // Integración Hive: actualización de estado en Hive
    final task = _taskBox.getAt(index);
    if (task != null) {
      task.done = !task.done;
      await task.save();
      notifyListeners();
    }
  }

  void removeTask(int index) async {
    // Integración Hive: eliminación de tarea en Hive
    final task = _taskBox.getAt(index);
    if (task != null) {
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }
      await task.delete();
      notifyListeners();
    }
  }

  void updateTask(int index, String newTitle, {DateTime? newDate, TimeOfDay? newTime, int? notificationId}) async {
    // Integración Hive: actualización de campos en tarea almacenada en Hive
    final task = _taskBox.getAt(index);
    if (task != null) {
      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }

      task.title = newTitle;
      task.dueDate = newDate;
      task.notificationId = notificationId;

      await task.save();
      notifyListeners();
    }
  }
}
