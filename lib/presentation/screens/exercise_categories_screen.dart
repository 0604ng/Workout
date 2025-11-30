// FILE: lib/presentation/screens/exercise_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../injection_container.dart';
import 'exercise_library_screen.dart';

class ExerciseCategoriesScreen extends StatelessWidget {
  final bool selectMode; // ← THÊM THAM SỐ NÀY

  const ExerciseCategoriesScreen({
    super.key,
    this.selectMode = true, // ← Mặc định là true cho chế độ chọn
  });

  Future<List<Map<String, dynamic>>> _loadCategories() async {
    final firestore = sl<FirebaseFirestore>();

    final snapshot = await firestore.collection('exercise_categories').get();

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
        title: Text(selectMode ? "Select Category" : "Exercise Categories"),
        elevation: 2,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger rebuild to retry
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No categories found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
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
                  onTap: () async {
                    // ← SỬA PHẦN NÀY: Truyền selectMode xuống ExerciseLibraryScreen
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseLibraryScreen(
                          category: cat['id'],
                          selectMode: selectMode, // ← Truyền selectMode
                        ),
                      ),
                    );

                    // ← Nếu có kết quả trả về, pop về màn hình trước
                    if (result != null && context.mounted) {
                      Navigator.pop(context, result);
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