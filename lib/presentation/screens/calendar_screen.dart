// FILE: lib/presentation/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../injection_container.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/repositories/plan_repository.dart';
import '../state/auth_provider.dart';
import 'plan_edit_screen.dart';

class CalendarScreen extends StatefulWidget {
  static const String routeName = '/calendar';
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<PlanEntity>> _events = {};
  late PlanRepository repo;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    repo = sl<PlanRepository>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMonthEvents(_focusedDay));
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _loadMonthEvents(DateTime focused) async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.currentUser?.uid; // Changed from 'user' to 'currentUser'
    if (userId == null || userId.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final firstDay = DateTime(focused.year, focused.month, 1);
    final lastDay = DateTime(focused.year, focused.month + 1, 1).subtract(const Duration(days: 1));
    final plans = await repo.getPlansInRange(userId, firstDay, DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59));
    final Map<DateTime, List<PlanEntity>> map = {};
    for (final p in plans) {
      final d = _normalize(p.date);
      map.putIfAbsent(d, () => []).add(p);
    }
    setState(() {
      _events = map;
      _loading = false;
    });
  }

  List<PlanEntity> _getEventsForDay(DateTime day) => _events[_normalize(day)] ?? [];

  Widget _buildMarker(DateTime day, List events) {
    if (events.isEmpty) return const SizedBox.shrink();
    return Positioned(
      bottom: 6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < (events.length > 3 ? 3 : events.length); i++)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle), // Added 'const'
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Calendar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TableCalendar<PlanEntity>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) {
              _focusedDay = focused;
              _loadMonthEvents(focused);
            },
            eventLoader: (day) => _getEventsForDay(day),
            calendarStyle: const CalendarStyle( // Added 'const'
              selectedDecoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                return _buildMarker(day, events);
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('EEEE, dd MMM yyyy').format(_selectedDay), style: const TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add plan'),
                  onPressed: () {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    final uid = auth.currentUser?.uid ?? ''; // Changed from 'user' to 'currentUser'
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PlanEditScreen(date: _selectedDay, userId: uid)),
                    ).then((_) => _loadMonthEvents(_focusedDay));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _getEventsForDay(_selectedDay).isEmpty
                ? const Center(child: Text('No Scheduled Plan Today'))
                : ListView.builder(
              itemCount: _getEventsForDay(_selectedDay).length,
              itemBuilder: (_, idx) {
                final plan = _getEventsForDay(_selectedDay)[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text('Plan ${plan.id}'),
                    subtitle: Text('Exercises: ${plan.exercises.length}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PlanEditScreen(plan: plan, date: plan.date, userId: plan.userId)),
                        ).then((_) => _loadMonthEvents(_focusedDay));
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}