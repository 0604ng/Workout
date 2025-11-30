import 'package:flutter/material.dart';
import '../../utils/seed_database.dart'; // chứa hàm seedDatabase()

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _loading = false;
  String _status = '';

  Future<void> _runSeeder() async {
    setState(() {
      _loading = true;
      _status = 'Đang import dữ liệu...';
    });

    try {
      // ✅ Gọi trực tiếp hàm seedDatabase() thay vì DatabaseSeeder().seedAll()
      await seedDatabase();

      if (!mounted) return;
      setState(() {
        _status = '✅ Import dữ liệu mẫu thành công!';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = '❌ Lỗi khi import: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 72, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Import dữ liệu mẫu vào Firestore',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.cloud_upload),
                label: Text(_loading ? 'Đang import...' : 'Import dữ liệu mẫu'),
                onPressed: _loading ? null : _runSeeder,
              ),
            ),
            const SizedBox(height: 16),
            if (_status.isNotEmpty)
              Text(
                _status,
                style: TextStyle(
                  color: _status.startsWith('✅') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
