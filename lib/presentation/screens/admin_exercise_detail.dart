// FILE: lib/presentation/screens/admin_exercise_detail.dart
import 'package:flutter/material.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../injection_container.dart';
import 'admin_exercise_editor.dart';

class AdminExerciseDetail extends StatefulWidget {
  final String categoryId;
  final String exerciseId;

  const AdminExerciseDetail({
    super.key,
    required this.categoryId,
    required this.exerciseId,
  });

  @override
  State<AdminExerciseDetail> createState() => _AdminExerciseDetailState();
}

class _AdminExerciseDetailState extends State<AdminExerciseDetail> {
  late final ExerciseRepository repo;
  ExerciseEntity? exercise;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    repo = sl<ExerciseRepository>();
    _load();
  }

  Future<void> _load() async {
    final data = await repo.fetchExerciseByCategoryAndId(
      widget.categoryId,
      widget.exerciseId,
    );

    setState(() {
      exercise = data;
      loading = false;
    });
  }

  Future<void> _delete() async {
    await repo.deleteExercise(widget.categoryId, widget.exerciseId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise?.title ?? "Chi tiết bài tập"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminExerciseEditor(
                    categoryId: widget.categoryId,
                    exerciseId: widget.exerciseId,
                  ),
                ),
              ).then((_) => _load());
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Xác nhận xoá"),
                  content: const Text("Bạn có chắc muốn xoá bài tập này?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Hủy"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Xoá"),
                    ),
                  ],
                ),
              );
              if (ok == true) _delete();
            },
          ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : exercise == null
          ? const Center(child: Text("Không tìm thấy bài tập"))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (exercise!.imageUrl.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              exercise!.imageUrl,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(height: 16),

        Text(
          exercise!.title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            const Icon(Icons.bar_chart),
            const SizedBox(width: 6),
            Text("Độ khó: ${exercise!.difficulty}"),
            const Spacer(),
            const Icon(Icons.timer),
            const SizedBox(width: 6),
            Text("${exercise!.durationSeconds ~/ 60} phút"),
          ],
        ),

        const Divider(height: 32),

        const Text(
          "Mô tả",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),

        const SizedBox(height: 8),

        Text(exercise!.description),
      ],
    );
  }
}
