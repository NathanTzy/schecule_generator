
import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final void Function(int) onRemove;
  const TaskList({super.key, required this.tasks, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.blueAccent),
            title: Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              "⏱ ${task.duration} min  •  🕒 ${task.deadline}  •  🚦 ${task.priority}",
              style: const TextStyle(fontSize: 13),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onRemove(index),
            ),
          ),
        );
      },
    );
  }
}