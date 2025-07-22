import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider_task/task_provider.dart';
import '../services/notification_service.dart';
import '../utils/translations.dart';
import '../provider_task/language_provider.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _controller = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      int? notificationId;
      DateTime? finalDueDate;

      await NotificationService.showImmediateNotification(
        title: Translations.get('taskAdded'),
        body: Translations.get('taskAddedMessage', {'task': text}),
        payload: '${Translations.get("task")}: $text',
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
          title: Translations.get('taskReminder'),
          body: '${Translations.get("dontForget")}: $text',
          scheduledDate: finalDueDate,
          payload: '${Translations.get("scheduledTask")}: $text ${Translations.get("for")} $finalDueDate',
          notificationId: notificationId,
        );
      }

      Provider.of<TaskProvider>(context, listen: false).addTask(
        text,
        dueDate: finalDueDate ?? _selectedDate,
        notificationId: notificationId,
      );

      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
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
      initialTime: TimeOfDay.now(),
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
                Translations.get('add_new_task'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: Translations.get('description'),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text(Translations.get('select_date')),
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
                    child: Text(Translations.get('select_time')),
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
                label: Text(Translations.get('add_task_button')),
              ),
            ],
          ),
        );
      },
    );
  }
}
