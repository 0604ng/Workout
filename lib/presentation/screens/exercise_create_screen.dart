import 'package:flutter/material.dart';
import '../../injection_container.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseCreateScreen extends StatefulWidget {
  const ExerciseCreateScreen({super.key});

  @override
  State<ExerciseCreateScreen> createState() => _ExerciseCreateScreenState();
}

class _ExerciseCreateScreenState extends State<ExerciseCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _setsCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  String? selectedDifficulty;
  String? selectedCategory;

  bool loading = false;

  late final ExerciseRepository repo;

  @override
  void initState() {
    super.initState();
    repo = sl<ExerciseRepository>();
  }

  Future<List<String>> _loadCategories() async {
    final snap = await FirebaseFirestore.instance
        .collection("exercise_categories")
        .get();

    return snap.docs.map((e) => e.id).toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDifficulty == null) {
      _showError("Please choose a difficulty");
      return;
    }
    if (selectedCategory == null) {
      _showError("Please choose a category");
      return;
    }

    setState(() => loading = true);

    final exercise = ExerciseEntity(
      id: "",
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      durationSeconds: int.parse(_durationCtrl.text.trim()),
      imageUrl: _imageCtrl.text.trim(),
      difficulty: selectedDifficulty!,
      category: selectedCategory!,
      calories: int.parse(_caloriesCtrl.text.trim()),
      // FIX: Thêm .trim() và xử lý nullable đúng cách
      reps: _repsCtrl.text.trim().isNotEmpty
          ? int.parse(_repsCtrl.text.trim())
          : null,
      sets: _setsCtrl.text.trim().isNotEmpty
          ? int.parse(_setsCtrl.text.trim())
          : null,
    );

    try {
      await repo.addExercise(selectedCategory!, exercise);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Exercise created successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Error: $e");
    }

    if (mounted) setState(() => loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Exercise")),
      body: FutureBuilder(
        future: _loadCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: "Title"),
                    validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                  ),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: "Description"),
                    minLines: 2,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 12),

                  // FIX: Bỏ thuộc tính 'value' vì đã deprecated
                  DropdownButtonFormField<String>(
                    items: ["easy", "medium", "hard"]
                        .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    decoration: const InputDecoration(labelText: "Difficulty"),
                    onChanged: (v) => setState(() => selectedDifficulty = v),
                    validator: (v) =>
                    v == null ? "Select difficulty" : null,
                  ),

                  // FIX: Bỏ thuộc tính 'value' vì đã deprecated
                  DropdownButtonFormField<String>(
                    items: categories
                        .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    decoration: const InputDecoration(labelText: "Category"),
                    onChanged: (v) => setState(() => selectedCategory = v),
                    validator: (v) =>
                    v == null ? "Select category" : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _durationCtrl,
                    decoration: const InputDecoration(
                        labelText: "Duration (seconds)"),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                  ),

                  TextFormField(
                    controller: _caloriesCtrl,
                    decoration: const InputDecoration(labelText: "Calories"),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                    v == null || v.isEmpty ? "Required" : null,
                  ),

                  TextFormField(
                    controller: _repsCtrl,
                    decoration:
                    const InputDecoration(labelText: "Reps (optional)"),
                    keyboardType: TextInputType.number,
                  ),

                  TextFormField(
                    controller: _setsCtrl,
                    decoration:
                    const InputDecoration(labelText: "Sets (optional)"),
                    keyboardType: TextInputType.number,
                  ),

                  TextFormField(
                    controller: _imageCtrl,
                    decoration:
                    const InputDecoration(labelText: "Image URL"),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text("Create Exercise"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}