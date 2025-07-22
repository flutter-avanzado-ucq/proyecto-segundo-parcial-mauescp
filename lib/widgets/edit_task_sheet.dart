import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';
import '../utils/translations.dart';
import '../provider_task/language_provider.dart';

class EditTaskSheet extends StatefulWidget {
  final int index;

  const EditTaskSheet({super.key, required this.index});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController _controller;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];
    _controller = TextEditingController(text: task.title);
    _selectedDate = task.dueDate;

    if (task.dueDate != null) {
      _selectedTime = TimeOfDay.fromDateTime(task.dueDate!);
    } else {
      _selectedTime = const TimeOfDay(hour: 8, minute: 0);
    }
  }

  void _submit() async {
    final newTitle = _controller.text.trim();
    if (newTitle.isNotEmpty) {
      int? notificationId;
      DateTime? finalDueDate;

      final task = Provider.of<TaskProvider>(context, listen: false).tasks[widget.index];

      if (task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }

      await NotificationService.showImmediateNotification(
        title: Translations.get('taskUpdated'),
        body: Translations.get('taskUpdatedMessage', {'task': newTitle}),
        payload: '${Translations.get("taskUpdated")}: $newTitle',
      );

      if (_selectedDate != null && _selectedTime != null) {
        finalDueDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );

        notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

        await NotificationService.scheduleNotification(
          title: Translations.get('taskReminderUpdated'),
          body: '${Translations.get("dontForget")}: $newTitle',
          scheduledDate: finalDueDate,
          payload: '${Translations.get("taskUpdated")}: $newTitle ${Translations.get("for")} $finalDueDate',
          notificationId: notificationId,
        );
      }

      Provider.of<TaskProvider>(context, listen: false).updateTask(
        widget.index,
        newTitle,
        newDate: finalDueDate ?? _selectedDate,
        notificationId: notificationId,
      );

      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Translations.get('edit_task_title'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: Translations.get('title'),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text(Translations.get('changeDate')),
                  ),
                  const SizedBox(width: 10),
                  if (_selectedDate != null)
                    Text('${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: Text(Translations.get('changeTime')),
                  ),
                  const SizedBox(width: 10),
                  Text('${Translations.get("hour")}: '),
                  if (_selectedTime != null)
                    Text('${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: Text(Translations.get('saveChanges')),
              ),
            ],
          ),
        );
      },
    );
  }
}
