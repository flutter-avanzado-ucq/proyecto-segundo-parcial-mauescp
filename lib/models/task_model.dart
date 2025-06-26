import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool done;

  @HiveField(2)
  DateTime? dueDate;

  @HiveField(3)
  int? notificationId;

  Task({
    required this.title,
    this.done = false,
    this.dueDate,
    this.notificationId,
  });
}

