// FILE: lib/presentation/screens/exercise_category_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../injection_container.dart';
import 'exercise_library_screen.dart';

class ExerciseCategoryDetailScreen extends StatelessWidget {
  final String categoryId;

  const ExerciseCategoryDetailScreen({
    super.key,
    required this.categoryId,
  });

  /// Load thông tin category
  Future<Map<String, dynamic>> _loadCategory() async {
    final firestore = sl<FirebaseFirestore>();

    final doc = await firestore
        .collection('exercise_categories')
        .doc(categoryId)
        .get();

    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final title = data["name"] ?? categoryId.toUpperCase();
        final description = data["description"] ?? "";

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            elevation: 1,
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 24),

                const Divider(),

                const SizedBox(height: 12),

                const Text(
                  "Category Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "View all exercises included in this category.",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.fitness_center),
                    label: const Text(
                      "View Exercises",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseLibraryScreen(
                            category: categoryId,
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
