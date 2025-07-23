import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';
class TaskProvider with ChangeNotifier {
  final Box<Task> _tasksBox = Hive.box<Task>('tasksBox');
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _tasksBox.values.toList();
    _tasks.sort((a, b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    task.notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _tasksBox.add(task);
    _loadTasks();

    if (task.dueDate != null) {
      await NotificationService.scheduleNotification(
        title: 'Tarea pendiente',
        body: task.title,
        scheduledDate: task.dueDate!,
        notificationId: task.notificationId!,
      );
    }
  }

  Future<void> removeTask(int index) async {
    final task = _tasks[index];
    if (task.notificationId != null) {
      await NotificationService.cancelNotification(task.notificationId!);
    }
    await task.delete();
    _loadTasks();
  }

  Future<void> toggleTask(int index) async {
    final task = _tasks[index];
    task.done = !task.done;
    if (task.done && task.notificationId != null) {
      await NotificationService.cancelNotification(task.notificationId!);
    }
    await task.save();
    _loadTasks();
  }

  Future<void> updateTask(int index, String title, {DateTime? newDate, int? notificationId}) async {
    final task = _tasks[index];
    
    if (task.notificationId != null) {
      await NotificationService.cancelNotification(task.notificationId!);
    }

    task.title = title;
    task.dueDate = newDate;
    task.notificationId = notificationId;
    await task.save();
    _loadTasks();
  }
}
