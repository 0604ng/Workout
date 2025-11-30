// FILE: lib/presentation/screens/exercise_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../injection_container.dart';
import 'exercise_library_screen.dart';

class ExerciseCategoriesScreen extends StatelessWidget {
  const ExerciseCategoriesScreen({super.key});

  Future<List<Map<String, dynamic>>> _loadCategories() async {
    final firestore = sl<FirebaseFirestore>();

    final snapshot =
    await firestore.collection('exercise_categories').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'name': data['name'] ?? doc.id.toUpperCase(),
        'description': data['description'] ?? '',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise Categories"),
        elevation: 2,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No categories found"));
          }

          final categories = snapshot.data!;

          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) {
              final cat = categories[i];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    cat['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    cat['description'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseLibraryScreen(
                          category: cat['id'],
                        ),
                      ),
                    );
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
