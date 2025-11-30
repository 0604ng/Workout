import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_exercise_list.dart';
import 'admin_exercise_editor.dart';

class AdminPanelScreen extends StatelessWidget {
  static const String routeName = '/admin-panel';

  const AdminPanelScreen({super.key});

  /// Lấy danh sách category theo realtime
  Stream<QuerySnapshot<Map<String, dynamic>>> _getCategories() {
    return FirebaseFirestore.instance
        .collection("exercise_categories")
        .orderBy("info.name")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel – Quản lý bài tập"),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs;

          if (categories.isEmpty) {
            return const Center(child: Text("Chưa có category nào!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final doc = categories[index];
              final categoryId = doc.id;
              final info = doc.data()["info"] ?? {};

              final name = info["name"] ?? categoryId.toUpperCase();
              final description = info["description"] ?? "Không có mô tả";

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: Text(description),

                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminExerciseEditor(
                            categoryId: categoryId,
                          ),
                        ),
                      );
                    },
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminExerciseList(
                          categoryId: categoryId,
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

      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Tạo category"),
        icon: const Icon(Icons.category),
        onPressed: () {
          _openCreateCategoryDialog(context);
        },
      ),
    );
  }

  /// Tạo category mới (UI đơn giản)
  void _openCreateCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tạo category mới"),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Tên category"),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Mô tả"),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),

          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection("exercise_categories")
                  .doc(name.toLowerCase().replaceAll(" ", "_"))
                  .set({
                "info": {
                  "name": name,
                  "description": descCtrl.text.trim(),
                }
              });
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Tạo"),
          ),
        ],
      ),
    );
  }
}
