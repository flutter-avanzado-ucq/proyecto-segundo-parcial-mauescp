import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class Task {
  String title;
  bool done;
  DateTime? dueDate;
  TimeOfDay? dueTime;
  int? notificationId;

  Task({
    required this.title,
    this.done = false,
    this.dueDate,
    this.dueTime,
    this.notificationId,
  });
}

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  void addTask(String title, {DateTime? dueDate, TimeOfDay? dueTime, int? notificationId}) {
    _tasks.insert(0, Task(
      title: title,
      dueDate: dueDate,
      dueTime: dueTime,
      notificationId: notificationId,
    ));
    notifyListeners();
  }

  void toggleTask(int index) {
    _tasks[index].done = !_tasks[index].done;
    notifyListeners();
  }

  void removeTask(int index) {
    final task = _tasks[index];
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }
    _tasks.removeAt(index);
    notifyListeners();
  }

  void updateTask(int index, String newTitle, {DateTime? newDate, TimeOfDay? newTime, int? notificationId}) {
    final task = _tasks[index];

    // Si ya tenía una notificación previa, cancelar
    if (task.notificationId != null) {
      NotificationService.cancelNotification(task.notificationId!);
    }

    _tasks[index].title = newTitle;
    _tasks[index].dueDate = newDate;
    _tasks[index].dueTime = newTime;
    _tasks[index].notificationId = notificationId;

    notifyListeners();
  }
}
