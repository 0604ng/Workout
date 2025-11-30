import 'package:flutter/material.dart';
import '../../utils/notification_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime? selectedTime;

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() => selectedTime = scheduledDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Workout")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _pickDateTime(context),
            child: const Text("Pick Date & Time"),
          ),
          if (selectedTime != null)
            Text("Selected: $selectedTime"),

          ElevatedButton(
            onPressed: selectedTime == null
                ? null
                : () {
              NotificationService.scheduleNotification(
                id: 1,
                date: selectedTime!,
                title: "Workout Time!",
                body: "Don't forget your training session 💪🔥",
              );
            },
            child: const Text("Save Schedule"),
          ),
        ],
      ),
    );
  }
}