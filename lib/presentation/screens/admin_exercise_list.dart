// FILE: lib/presentation/screens/admin_exercise_list.dart
import 'package:flutter/material.dart';
import '../../injection_container.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import 'admin_exercise_editor.dart';
import 'admin_exercise_detail.dart';

class AdminExerciseList extends StatefulWidget {
  final String categoryId; // luôn có category

  const AdminExerciseList({super.key, required this.categoryId});

  @override
  State<AdminExerciseList> createState() => _AdminExerciseListState();
}

class _AdminExerciseListState extends State<AdminExerciseList> {
  late final ExerciseRepository repo;

  bool loading = true;
  List<ExerciseEntity> items = [];

  @override
  void initState() {
    super.initState();
    repo = sl<ExerciseRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    items = await repo.fetchExercisesByCategory(widget.categoryId);

    if (mounted) setState(() => loading = false);
  }

  Future<void> _delete(String id) async {
    await repo.deleteExercise(widget.categoryId, id);
    _load();
  }

  void _openEditor({String? exerciseId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminExerciseEditor(
          categoryId: widget.categoryId,
          exerciseId: exerciseId,
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quản lý bài tập: ${widget.categoryId.toUpperCase()}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openEditor(),
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("Không có bài tập nào"))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final ex = items[i];

          return ListTile(
            leading: ex.imageUrl.isNotEmpty
                ? Image.network(ex.imageUrl, width: 60, height: 60)
                : const Icon(Icons.image),

            title: Text(ex.title),
            subtitle: Text(
              "${ex.difficulty} • ${ex.durationSeconds ~/ 60} phút",
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminExerciseDetail(
                    categoryId: widget.categoryId,
                    exerciseId: ex.id,
                  ),
                ),
              );
            },

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _openEditor(exerciseId: ex.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _delete(ex.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
