// lib/presentation/screens/exercise_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../injection_container.dart';

class ExerciseEditScreen extends StatefulWidget {
  final String exerciseId;
  final String categoryId;

  const ExerciseEditScreen({
    super.key,
    required this.exerciseId,
    required this.categoryId,
  });

  @override
  State<ExerciseEditScreen> createState() => _ExerciseEditScreenState();
}

class _ExerciseEditScreenState extends State<ExerciseEditScreen> {
  late final ExerciseRepository repo;

  final _formKey = GlobalKey<FormState>();

  bool loading = true;
  bool saving = false;

  // Controllers
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final imageC = TextEditingController();
  final durationC = TextEditingController();
  final caloriesC = TextEditingController();
  final repsC = TextEditingController();
  final setsC = TextEditingController();

  String difficulty = "medium";
  String category = "";

  ExerciseEntity? exercise;

  @override
  void initState() {
    super.initState();
    repo = sl<ExerciseRepository>();
    _load();
  }

  Future<void> _load() async {
    final ex = await repo.fetchExerciseByCategoryAndId(
      widget.categoryId,
      widget.exerciseId,
    );

    if (mounted) {
      if (ex != null) {
        exercise = ex;
        titleC.text = ex.title;
        descC.text = ex.description;
        imageC.text = ex.imageUrl;
        durationC.text = ex.durationSeconds.toString();
        caloriesC.text = ex.calories.toString();
        repsC.text = ex.reps?.toString() ?? "";
        setsC.text = ex.sets?.toString() ?? "";
        difficulty = ex.difficulty;
        category = ex.category;
      }
      loading = false;
      setState(() {});
    }
  }


  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final updated = ExerciseEntity(
      id: widget.exerciseId,
      title: titleC.text.trim(),
      description: descC.text.trim(),
      imageUrl: imageC.text.trim(),
      durationSeconds: int.tryParse(durationC.text.trim()) ?? 0,
      difficulty: difficulty,
      category: category,
      calories: int.tryParse(caloriesC.text.trim()) ?? 0,
      reps: repsC.text.isEmpty ? null : int.parse(repsC.text),
      sets: setsC.text.isEmpty ? null : int.parse(setsC.text),
    );

    await repo.updateExercise(category, widget.exerciseId, updated);

    if (mounted) {
      setState(() => saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Exercise updated successfully")),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Exercise"),
        actions: [
          TextButton(
            onPressed: saving ? null : _save,
            child: saving
                ? const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(color: Colors.white),
            )
                : const Text("SAVE", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // IMAGE PREVIEW
            if (imageC.text.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageC.text,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            _buildField("Title", titleC),
            _buildField("Description", descC, maxLines: 3),
            _buildField("Image URL", imageC),
            _buildField("Duration (seconds)", durationC, keyboard: TextInputType.number),
            _buildField("Calories", caloriesC, keyboard: TextInputType.number),
            _buildField("Reps (optional)", repsC, keyboard: TextInputType.number),
            _buildField("Sets (optional)", setsC, keyboard: TextInputType.number),

            const SizedBox(height: 20),

            // Difficulty
            _buildDropdown(
              label: "Difficulty",
              value: difficulty,
              items: const ["easy", "medium", "hard"],
              onChanged: (v) => setState(() => difficulty = v!),
            ),

            const SizedBox(height: 20),

            // Category
            _buildDropdown(
              label: "Category",
              value: category,
              items: const [
                "abs",
                "chest",
                "arm",
                "back",
                "legs",
                "butt",
                "warmup",
                "shoulder",
                "upperbody",
                "lowerbody",
              ],
              onChanged: (v) => setState(() => category = v!),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helpers
  Widget _buildField(
      String label,
      TextEditingController c, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return "Required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            isExpanded: true,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                .toList(),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
