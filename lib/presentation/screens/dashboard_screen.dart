import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/auth_provider.dart';
import '../../domain/entities/workout_log_entity.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Studio'),
        actions: [
          if (auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => auth.signOut(),
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerBox(auth),

          const SizedBox(height: 20),
          const Text("Exercise", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          _menuButton(context, Icons.grid_view, "Exercise Categories", "/exercise_categories"),
          _menuButtonWithArgs(
            context,
            Icons.library_books,
            "Exercise Library",
            "/exercise_library",
            arguments: {'category': 'cardio'},
          ),
          _menuButton(context, Icons.add, "Create Exercise", "/exercise_create"),

          const SizedBox(height: 25),
          const Text("Workout", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          _menuButtonWithArgs(
            context,
            Icons.play_circle_fill,
            "Start Workout ",
            "/start_workout",
            arguments: {'exercises': []},
          ),
          _menuButtonWithArgs(
            context,
            Icons.flag,
            "Workout Completed",
            "/workout_completed",
            arguments: {
              'exercises': <WorkoutExerciseLog>[],
              'totalCalories': 0,
              'totalDuration': 0,
            },
          ),

          const SizedBox(height: 25),
          const Text("Schedule", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          _menuButton(context, Icons.calendar_month, "Calendar", "/calendar"),
          _menuButton(context, Icons.schedule, "Schedule", "/schedule"),

          const SizedBox(height: 25),
          const Text("Plans", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          _menuButtonWithArgs(
            context,
            Icons.edit,
            "Edit Plan ",
            "/plan_edit",
            arguments: {
              'date': DateTime.now(),
              'userId': auth.currentUser?.uid ?? 'guest',
            },
          ),

          // 🔥🔥 HIỂN THỊ ADMIN MENU CHỈ CHO ADMIN
          if (auth.isAdmin) ...[
            const SizedBox(height: 25),
            const Text("Admin", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            _menuButton(context, Icons.admin_panel_settings, "Admin Panel", "/admin_panel"),
            _menuButton(context, Icons.manage_accounts, "Admin Screen", "/admin_screen"),
            _menuButtonWithArgs(
              context,
              Icons.list_alt,
              "Admin Exercise List",
              "/admin_exercise_list",
              arguments: {'categoryId': 'cardio'},
            ),
            _menuButtonWithArgs(
              context,
              Icons.edit_note,
              "Admin Exercise Editor",
              "/admin_exercise_editor",
              arguments: {'categoryId': 'cardio'},
            ),
          ],

          const SizedBox(height: 25),
          const Text("Authentication", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          _menuButton(context, Icons.logout, "Logout", "/logout"),
        ],
      ),
    );
  }

  Widget _headerBox(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            auth.currentUser?.email ?? "Guest",
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, IconData icon, String title, String route) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple, size: 32),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }

  Widget _menuButtonWithArgs(
      BuildContext context,
      IconData icon,
      String title,
      String route, {
        required Map<String, dynamic> arguments,
      }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple, size: 32),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route, arguments: arguments),
      ),
    );
  }
}
