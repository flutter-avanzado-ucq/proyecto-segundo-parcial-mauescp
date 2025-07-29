import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../widgets/card_tarea.dart';
import '../widgets/header.dart';
import '../widgets/add_task_sheet.dart';
import '../provider_task/task_provider.dart';
import '../provider_task/theme_provider.dart';
import 'package:flutter_animaciones_notificaciones/provider_task/language_provider.dart';
import '../utils/translations.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).notifyListeners();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = taskProvider.tasks;
        print('Construyendo TaskScreen con ${tasks.length} tareas');
        return Scaffold(
          appBar: AppBar(
           title: Consumer<LanguageProvider>(
             builder: (context, languageProvider, child) {
               return Text(Translations.get('appTitle'));
             },
            ),
            actions: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                    ),
                    tooltip: Translations.get('changeTheme'),
                    onPressed: () {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return IconButton(
                    icon: const Icon(Icons.language),
                    tooltip: Translations.get('changeLanguage'),
                    onPressed: () async {
                      await languageProvider.toggleLanguage();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              Translations.get('language_changed', {
                                'lang': languageProvider.currentLanguage == 'es' ? 'Español' : 'English'
                              })
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const Header(),
                Expanded(
                  child: tasks.isEmpty
                      ? Center(
                          child: Text(
                            Translations.get('noPendingTasks'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  verticalOffset: 30.0,
                                  child: FadeInAnimation(
                                    child: Dismissible(
                                      key: ValueKey(task.key),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (_) => taskProvider.removeTask(index),
                                      background: Container(
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade300,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.delete, color: Colors.white),
                                      ),
                                      child: TaskCard(
                                        key: ValueKey(task.key),
                                        title: task.title,
                                        isDone: task.done,
                                        dueDate: task.dueDate,
                                        onToggle: () {
                                          taskProvider.toggleTask(index);
                                          _iconController.forward(from: 0);
                                        },
                                        onDelete: () => taskProvider.removeTask(index),
                                        iconRotation: _iconController,
                                        index: index,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddTaskSheet,
            backgroundColor: Colors.pinkAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.calendar_today),
          ),
        );
      },
    );
  }
}
