import 'package:flutter/material.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../injection_container.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  final String category;
  final bool selectMode; // Thêm tham số này để phân biệt 2 chế độ

  const ExerciseLibraryScreen({
    super.key,
    required this.category,
    this.selectMode = false, // Mặc định là chế độ xem
  });

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  late final ExerciseRepository repo;
  late Future<List<ExerciseEntity>> future;

  @override
  void initState() {
    super.initState();
    repo = sl<ExerciseRepository>();
    future = repo.fetchAllExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.selectMode
              ? "Select ${widget.category} Exercise"
              : "${widget.category} Exercises",
        ),
      ),
      body: FutureBuilder<List<ExerciseEntity>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No exercises found"));
          }

          final all = snapshot.data!;
          final exercises =
          all.where((e) => e.category == widget.category).toList();

          if (exercises.isEmpty) {
            return Center(child: Text("No ${widget.category} exercises"));
          }

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (_, i) {
              final ex = exercises[i];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                  // === FIX LEADING SIZE BUG ===
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ex.imageUrl.isNotEmpty
                          ? Image.network(
                        ex.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 32),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.fitness_center, size: 32),
                      ),
                    ),
                  ),

                  title: Text(
                    ex.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(
                    ex.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Thêm trailing để hiện icon khi ở chế độ chọn
                  trailing: widget.selectMode
                      ? const Icon(Icons.add_circle_outline, color: Colors.green)
                      : null,

                  onTap: () {
                    if (widget.selectMode) {
                      // Chế độ chọn: Trả về exercise đã chọn
                      Navigator.pop(context, ex);
                    } else {
                      // Chế độ xem: Navigate đến detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseDetailScreen(
                            categoryId: widget.category,
                            exerciseId: ex.id,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}