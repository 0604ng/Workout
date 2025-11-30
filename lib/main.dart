import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'domain/entities/exercise_entity.dart';
import 'domain/entities/workout_log_entity.dart';
import 'firebase_options.dart';

import 'notification_service.dart';
import 'presentation/state/auth_provider.dart';

// ===== Screens =====
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';

import 'presentation/screens/exercise_categories_screen.dart';
import 'presentation/screens/exercise_detail_screen.dart';
import 'presentation/screens/exercise_create_screen.dart';
import 'presentation/screens/exercise_edit_screen.dart';
import 'presentation/screens/exercise_library_screen.dart';

import 'presentation/screens/admin_screen.dart';
import 'presentation/screens/admin_panel_screen.dart';
import 'presentation/screens/admin_exercise_list.dart';
import 'presentation/screens/admin_exercise_editor.dart';

import 'presentation/screens/start_workout_screen.dart';
import 'presentation/screens/workout_completed_screen.dart';

import 'presentation/screens/plan_edit_screen.dart';
import 'presentation/screens/calendar_screen.dart';
import 'presentation/screens/schedule_screen.dart';

import 'package:provider/provider.dart';
import 'injection_container.dart' as di;
import 'utils/seed_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.init();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await di.init();
  _seedDatabaseSafely();

  runApp(const WorkoutApp());
}

void _seedDatabaseSafely() {
  Future.delayed(const Duration(seconds: 2), () async {
    try {
      await seedDatabase();
    } catch (e) {
      debugPrint("⚠️ Seed failed: $e");
    }
  });
}

class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Workout App',

        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: const Color(0xFF0F0F12),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
        ),

        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return StreamBuilder(
              stream: auth.authStateChanges,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.hasData
                    ? const DashboardScreen()
                    : const LoginScreen();
              },
            );
          },
        ),

        // -------- ROUTES -------- //
        routes: {
          '/dashboard': (_) => const DashboardScreen(),

          // Auth
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forgot_password': (_) => const ForgotPasswordScreen(),

          // Exercise Screens
          '/exercise_categories': (_) => const ExerciseCategoriesScreen(),
          '/exercise_create': (_) => const ExerciseCreateScreen(),
          '/exercise_library': (_) =>
          const ExerciseLibraryScreen(category: "abs"),

          // Plan + Calendar
          '/calendar': (_) => const CalendarScreen(),
          '/schedule': (_) => const ScheduleScreen(),

          // Admin
          '/admin_screen': (_) => const AdminScreen(),
          '/admin_panel': (_) => const AdminPanelScreen(),
        },

        // ------ Dynamic Routes ------ //
        onGenerateRoute: (settings) {
          // Plan Edit - Dynamic route với DateTime
          if (settings.name == '/plan_edit') {
            final args = settings.arguments as Map<String, dynamic>?;

            // Parse date từ String sang DateTime
            DateTime date;
            if (args?['date'] is DateTime) {
              date = args!['date'] as DateTime;
            } else if (args?['date'] is String) {
              // Nếu là String, parse thành DateTime
              date = DateTime.tryParse(args!['date'] as String) ?? DateTime.now();
            } else {
              date = DateTime.now();
            }

            return MaterialPageRoute(
              builder: (_) => PlanEditScreen(
                date: date,
                userId: args?['userId'] ?? '',
              ),
            );
          }

          // Admin Exercise List - Dynamic route
          if (settings.name == '/admin_exercise_list') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => AdminExerciseList(
                categoryId: args?['categoryId'] ?? '',
              ),
            );
          }

          // Admin Exercise Editor - Dynamic route
          if (settings.name == '/admin_exercise_editor') {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => AdminExerciseEditor(
                categoryId: args?['categoryId'] ?? '',
              ),
            );
          }

          if (settings.name == '/exercise_detail') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ExerciseDetailScreen(
                exerciseId: args['exerciseId'],
                categoryId: args['categoryId'] ?? '',
              ),
            );
          }

          if (settings.name == '/exercise_edit') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ExerciseEditScreen(
                exerciseId: args['exerciseId'],
                categoryId: args['categoryId'],
              ),
            );
          }

          if (settings.name == '/start_workout') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => StartWorkoutScreen(
                exercises: (args['exercises'] as List<dynamic>)
                    .cast<ExerciseEntity>(), // ✅ Cast sang List<ExerciseEntity>
              ),
            );
          }

          // Workout Completed - chỉ truyền 3 tham số theo constructor
          if (settings.name == '/workout_completed') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => WorkoutCompletedScreen(
                exercises: (args['exercises'] as List<dynamic>)
                    .cast<WorkoutExerciseLog>(), // ✅ Cast sang List<WorkoutExerciseLog>
                totalCalories: args['totalCalories'] as int,
                totalDuration: args['totalDuration'] as int,
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}