import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/edit_task_sheet.dart';
import '../utils/translations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/language_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/holiday_provider.dart';

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

  Widget _buildDateInfo(BuildContext context, DateTime date) {
    final holidayProvider = Provider.of<HolidayProvider>(context);
    final isHoliday = holidayProvider.isHoliday(date);
    final holidayName = holidayProvider.getHolidayName(date);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Consumer<LanguageProvider>(
                builder: (context, lang, _) {
                  final dueLabel = lang.getTranslation('due');
                  return Text(
                    '$dueLabel: ${DateFormat('dd/MM/yyyy').format(date)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  );
                },
              ),
              Consumer<LanguageProvider>(
                builder: (context, lang, _) {
                  final timeLabel = lang.getTranslation('time');
                  return Text(
                    '$timeLabel: ${DateFormat('HH:mm').format(date)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  );
                },
              ),
            ],
          ),
          if (isHoliday) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: 16,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Translations.get('holiday_label', {'name': holidayName ?? ''}),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

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
                  if (dueDate != null) _buildDateInfo(context, dueDate!),
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
