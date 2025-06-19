
import 'package:flutter/material.dart';

class ScheduleResultCard extends StatelessWidget {
  final String schedule;
  const ScheduleResultCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          schedule,
          style: const TextStyle(fontSize: 15, height: 1.5),
        ),
      ),
    );
  }
}