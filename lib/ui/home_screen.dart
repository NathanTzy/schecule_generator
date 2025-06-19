import 'package:flutter/material.dart';
import 'package:flutter_schedule_generator/models/task.dart';
import 'package:flutter_schedule_generator/services/gemini_service.dart';
import 'package:intl/intl.dart';

import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> tasks = [];
  bool isLoading = false;
  String scheduleResult = "";
  String? priority;
  final taskController = TextEditingController();
  final durationController = TextEditingController();
  final deadlineController = TextEditingController();
  final GeminiService geminiService = GeminiService();

  void _addTask() {
    if (taskController.text.isNotEmpty &&
        durationController.text.isNotEmpty &&
        deadlineController.text.isNotEmpty &&
        priority != null) {
      setState(() {
        tasks.add(Task(
          name: taskController.text,
          priority: priority!,
          duration: int.tryParse(durationController.text) ?? 5,
          deadline: deadlineController.text,
        ));
      });
      taskController.clear();
      durationController.clear();
      deadlineController.clear();
      setState(() {
        priority = null;
      });
    }
  }

  Future<void> _generateSchedule() async {
    setState(() => isLoading = true);
    try {
      String schedule = await geminiService.generateSchedule(tasks);
      setState(() => scheduleResult = schedule);
    } catch (e) {
      setState(() => scheduleResult = "Failed to generate schedule: $e");
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Generator"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const SectionTitle(title: "Add New Task"),
            const SizedBox(height: 10),
            TaskInputCard(
              taskController: taskController,
              durationController: durationController,
              deadlineController: deadlineController,
              priority: priority,
              onPriorityChanged: (val) => setState(() => priority = val),
              onAddTask: _addTask,
            ),
            const SizedBox(height: 30),
            const SectionTitle(title: "Your Tasks"),
            const SizedBox(height: 10),
            tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No tasks added yet.",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : TaskList(
                    tasks: tasks,
                    onRemove: (i) => setState(() => tasks.removeAt(i)),
                  ),
            const SizedBox(height: 30),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : GenerateButton(onPressed: _generateSchedule),
            const SizedBox(height: 30),
            if (scheduleResult.isNotEmpty) ...[
              const SectionTitle(title: "Generated Schedule"),
              const SizedBox(height: 10),
              ScheduleResultCard(schedule: scheduleResult),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }
}

class TaskInputCard extends StatelessWidget {
  final TextEditingController taskController;
  final TextEditingController durationController;
  final TextEditingController deadlineController;
  final String? priority;
  final void Function(String?) onPriorityChanged;
  final VoidCallback onAddTask;

  const TaskInputCard({
    super.key,
    required this.taskController,
    required this.durationController,
    required this.deadlineController,
    required this.priority,
    required this.onPriorityChanged,
    required this.onAddTask,
  });

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isNumber = false,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: taskController,
              label: "Task Name",
              hint: "e.g. Learn Flutter",
              icon: Icons.task,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 0, minute: 30),
                  helpText: "Select Duration (HH:MM)",
                );
                if (picked != null) {
                  durationController.text = "${picked.hour}h ${picked.minute}m";
                }
              },
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: durationController,
                  label: "Duration",
                  hint: "Select duration (hh:mm)",
                  icon: Icons.timer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  deadlineController.text =
                      DateFormat('yyyy-MM-dd').format(picked);
                }
              },
              child: AbsorbPointer(
                child: _buildTextField(
                  controller: deadlineController,
                  label: "Deadline",
                  hint: "e.g. 2025-06-25",
                  icon: Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: priority,
              decoration: InputDecoration(
                labelText: "Priority",
                hintText: "Choose priority",
                prefixIcon: const Icon(Icons.priority_high),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: const ["High", "Medium", "Low"]
                  .map((val) => DropdownMenuItem(
                        value: val,
                        child: Text(val),
                      ))
                  .toList(),
              onChanged: onPriorityChanged,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text("Add Task"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
