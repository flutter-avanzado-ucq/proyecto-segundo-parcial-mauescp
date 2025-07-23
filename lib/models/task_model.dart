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
  String? key;

  @HiveField(4)
  int? notificationId;

  Task({
    required this.title,
    required this.done,
    this.dueDate,
    this.key,
    this.notificationId,
  }) {
    key = key ?? DateTime.now().millisecondsSinceEpoch.toString();
  }
}
