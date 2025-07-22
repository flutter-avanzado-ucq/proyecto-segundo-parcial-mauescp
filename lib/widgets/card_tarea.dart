import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/edit_task_sheet.dart';
import '../utils/translations.dart';
import 'package:provider/provider.dart';
import '../provider_task/language_provider.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Animation<double> iconRotation;
  final DateTime? dueDate;
  final int index;

  const TaskCard({
    super.key,
    required this.title,
    required this.isDone,
    required this.onToggle,
    required this.onDelete,
    required this.iconRotation,
    required this.index,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: isDone ? 0.4 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFD0F0C0) : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListTile(
              leading: GestureDetector(
                onTap: onToggle,
                child: AnimatedBuilder(
                  animation: iconRotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: iconRotation.value * pi,
                      child: Icon(
                        isDone ? Icons.refresh : Icons.radio_button_unchecked,
                        color: isDone ? Colors.teal : Colors.grey,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      fontSize: 18,
                      color: isDone ? Colors.black45 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '${Translations.get("due")}: ${DateFormat('dd/MM/yyyy').format(dueDate!)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${Translations.get("time")}: ${DateFormat('HH:mm').format(dueDate!)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: Translations.get('editTask'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => EditTaskSheet(index: index),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: Translations.get('deleteTask'),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
