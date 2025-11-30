// FILE: lib/presentation/screens/plan_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../injection_container.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/plan_repository.dart';
import 'exercise_categories_screen.dart'; // ← THAY ĐỔI IMPORT

class PlanEditScreen extends StatefulWidget {
  final PlanEntity? plan;
  final DateTime date;
  final String userId;

  const PlanEditScreen({
    super.key,
    this.plan,
    required this.date,
    required this.userId,
  });

  @override
  State<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends State<PlanEditScreen> {
  final List<ExerciseEntity> _selectedExercises = [];
  late PlanRepository repo;

  @override
  void initState() {
    super.initState();
    repo = sl<PlanRepository>();
    if (widget.plan != null) {
      _selectedExercises.addAll(widget.plan!.exercises);
    }
  }

  void _showAddExerciseDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final durationController = TextEditingController();
    final imageUrlController = TextEditingController();
    String selectedDifficulty = 'beginner';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Exercise"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Exercise name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: "Duration (seconds)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: "Image URL (optional)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: "Difficulty",
                    border: OutlineInputBorder(),
                  ),
                  items: ['beginner', 'intermediate', 'advanced']
                      .map((diff) => DropdownMenuItem(
                    value: diff,
                    child: Text(diff.toUpperCase()),
                  ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedDifficulty = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter exercise name')),
                  );
                  return;
                }

                final ex = ExerciseEntity(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? 'Custom exercise'
                      : descriptionController.text.trim(),
                  durationSeconds: int.tryParse(durationController.text) ?? 60,
                  imageUrl: imageUrlController.text.trim(),
                  difficulty: selectedDifficulty,
                  category: 'custom',
                  calories: 0,
                  reps: null,
                  sets: null,
                );
                setState(() => _selectedExercises.add(ex));
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePlan() async {
    if (_selectedExercises.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one exercise')),
        );
      }
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final id = widget.plan?.id ?? const Uuid().v4();
      final plan = PlanEntity(
        id: id,
        userId: widget.userId,
        date: widget.date,
        exercises: _selectedExercises,
      );

      if (widget.plan == null) {
        await repo.createPlan(plan);
      } else {
        await repo.updatePlan(plan);
      }

      if (mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error saving plan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan == null ? "Create Plan" : "Edit Plan"),
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedExercises.isEmpty
                ? const Center(
              child: Text(
                'No exercises added yet.\nTap "Add Exercise" or "Choose from Library"',
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: _selectedExercises.length,
              itemBuilder: (_, i) {
                final ex = _selectedExercises[i];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: ex.imageUrl.isNotEmpty
                        ? Image.network(
                      ex.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.fitness_center),
                    )
                        : const Icon(Icons.fitness_center),
                    title: Text(ex.title),
                    subtitle: Text(
                      "${ex.difficulty.toUpperCase()} • ${ex.durationSeconds ~/ 60} min\n${ex.description}",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(
                            () => _selectedExercises.removeAt(i),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddExerciseDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Exercise"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    // ← SỬA PHẦN NÀY: Chuyển đến ExerciseCategoriesScreen
                    final selected = await Navigator.push<ExerciseEntity>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExerciseCategoriesScreen(),
                      ),
                    );

                    if (selected != null && mounted) {
                      setState(() => _selectedExercises.add(selected));
                    }
                  },
                  icon: const Icon(Icons.list),
                  label: const Text("Choose from Library"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _savePlan,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "Save Plan",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}