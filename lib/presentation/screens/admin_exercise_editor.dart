// FILE: lib/presentation/screens/admin_exercise_editor.dart
import 'package:flutter/material.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../injection_container.dart';

class AdminExerciseEditor extends StatefulWidget {
  final String categoryId;
  final String? exerciseId; // null = tạo mới

  const AdminExerciseEditor({
    super.key,
    required this.categoryId,
    this.exerciseId,
  });

  @override
  State<AdminExerciseEditor> createState() => _AdminExerciseEditorState();
}

class _AdminExerciseEditorState extends State<AdminExerciseEditor> {
  final formKey = GlobalKey<FormState>();
  late final ExerciseRepository repo;

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
  final imageCtrl = TextEditingController();
  final caloriesCtrl = TextEditingController();

  String difficulty = "medium";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    repo = sl<ExerciseRepository>();
    if (widget.exerciseId != null) _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    final data = await repo.fetchExerciseByCategoryAndId(
      widget.categoryId,
      widget.exerciseId!,
    );

    if (data != null) {
      titleCtrl.text = data.title;
      descCtrl.text = data.description;
      durationCtrl.text = data.durationSeconds.toString();
      imageCtrl.text = data.imageUrl;
      caloriesCtrl.text = data.calories.toString();
      difficulty = data.difficulty;
    }

    setState(() => loading = false);
  }

  Future<void> _save() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final entity = ExerciseEntity(
      id: widget.exerciseId ?? "",
      title: titleCtrl.text,
      description: descCtrl.text,
      durationSeconds: int.parse(durationCtrl.text),
      imageUrl: imageCtrl.text,
      difficulty: difficulty,
      category: widget.categoryId,
      calories: int.tryParse(caloriesCtrl.text) ?? 0,
    );

    if (widget.exerciseId == null) {
      await repo.addExercise(widget.categoryId, entity);
    } else {
      await repo.updateExercise(widget.categoryId, widget.exerciseId!, entity);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.exerciseId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Chỉnh sửa bài tập" : "Thêm bài tập mới"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên bài tập",
                ),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Mô tả",
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Thời lượng (giây)",
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: caloriesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Calories",
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: imageCtrl,
                decoration: const InputDecoration(
                  labelText: "Link ảnh",
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField(
                initialValue: difficulty,
                items: const [
                  DropdownMenuItem(value: "easy", child: Text("Dễ")),
                  DropdownMenuItem(value: "medium", child: Text("Trung bình")),
                  DropdownMenuItem(value: "hard", child: Text("Khó")),
                ],
                onChanged: (v) => setState(() => difficulty = v!),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(isEdit ? "Cập nhật" : "Tạo mới"),
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
