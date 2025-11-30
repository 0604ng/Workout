import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

/// ---------------------------------------------------------
/// SEED DATABASE (OPTIMIZED WITH RETRY LOGIC)
/// ---------------------------------------------------------

Future<void> seedDatabase() async {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  if (auth.currentUser == null) {
    debugPrint("⚠️ Please login before seeding Firestore!");
    return;
  }

  final uid = auth.currentUser!.uid;
  final email = auth.currentUser!.email ?? "user@example.com";


  debugPrint("🌱 Starting optimized Firestore seeding");

  try {
    await _seedAdmin(firestore, uid);
    await _seedUserProfile(firestore, uid, email);
    await _seedExerciseCategoriesAndItems(firestore);
    await _seedWorkoutPlan(firestore, uid);
    await _seedWorkoutLog(firestore, uid);

    debugPrint("🎉 Firestore seeding complete!");
  } catch (e) {
    debugPrint("❌ Seeding failed: $e");
    rethrow;
  }
}

/// ---------------------------------------------------------
/// Helper: Safe get with retry
/// ---------------------------------------------------------
Future<DocumentSnapshot> _safeGet(
    DocumentReference doc, {
      int maxRetries = 3,
    }) async {
  int attempt = 0;

  while (attempt < maxRetries) {
    try {
      return await doc.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          debugPrint('⏱️ Timeout on attempt ${attempt + 1}, retrying...');
          throw TimeoutException('Document get timeout');
        },
      );
    } on FirebaseException catch (e) {
      attempt++;
      if (e.code == 'unavailable' && attempt < maxRetries) {
        final delay = pow(2, attempt).toInt();
        debugPrint('🔄 Retry $attempt/$maxRetries after ${delay}s...');
        await Future.delayed(Duration(seconds: delay));
      } else {
        rethrow;
      }
    }
  }

  throw Exception('Failed after $maxRetries attempts');
}

/// ---------------------------------------------------------
/// Helper: Safe query with retry
/// ---------------------------------------------------------
Future<QuerySnapshot> _safeQuery(
    Query query, {
      int maxRetries = 3,
    }) async {
  int attempt = 0;

  while (attempt < maxRetries) {
    try {
      return await query.get().timeout(
        const Duration(seconds: 10),
      );
    } on FirebaseException catch (e) {
      attempt++;
      if (e.code == 'unavailable' && attempt < maxRetries) {
        final delay = pow(2, attempt).toInt();
        debugPrint('🔄 Query retry $attempt/$maxRetries after ${delay}s...');
        await Future.delayed(Duration(seconds: delay));
      } else {
        rethrow;
      }
    }
  }

  throw Exception('Query failed after $maxRetries attempts');
}

/// ---------------------------------------------------------
/// 1) Seed admin
/// ---------------------------------------------------------
Future<void> _seedAdmin(FirebaseFirestore firestore, String uid) async {
  try {
    final adminDoc = firestore.collection('admin').doc(uid);
    final snapshot = await _safeGet(adminDoc);

    if (!snapshot.exists) {
      await adminDoc.set({'isAdmin': true});
      debugPrint("✅ Admin created");
    } else {
      debugPrint("➖ Admin exists (skip)");
    }
  } catch (e) {
    debugPrint("⚠️ Admin seed failed: $e");
  }
}

/// ---------------------------------------------------------
/// 2) Seed user profile
/// ---------------------------------------------------------
Future<void> _seedUserProfile(
    FirebaseFirestore firestore, String uid, String email) async {
  try {
    final userDoc = firestore.collection('users').doc(uid);
    final snapshot = await _safeGet(userDoc);

    if (!snapshot.exists) {
      await userDoc.set({
        'email': email,
        'username': email.split('@')[0],
        'dob': DateTime(2000, 1, 1).toIso8601String(),
        'location': 'Hanoi, Vietnam',
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint("✅ User profile created");
    } else {
      debugPrint("➖ User profile exists (skip)");
    }
  } catch (e) {
    debugPrint("⚠️ User profile seed failed: $e");
  }
}

/// ---------------------------------------------------------
/// 3) Seed exercise categories + items (with retry)
/// ---------------------------------------------------------
Future<void> _seedExerciseCategoriesAndItems(FirebaseFirestore firestore) async {
  debugPrint("📌 Seeding categories + exercises...");

  final Map<String, List<Map<String, dynamic>>> categories = _exerciseData();

  for (final entry in categories.entries) {
    final categoryId = entry.key;
    final items = entry.value;

    try {
      final catDoc = firestore.collection('exercise_categories').doc(categoryId);
      final catSnapshot = await _safeGet(catDoc);

      // Create category only if missing
      if (!catSnapshot.exists) {
        await catDoc.set({
          'id': categoryId,
          'name': categoryId.toUpperCase(),
          'description': "Exercises for ${categoryId.toUpperCase()}",
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint("✅ Category created: $categoryId");
      }

      // Seed all exercises with delay to avoid overwhelming
      for (int i = 0; i < items.length; i++) {
        final exercise = items[i];
        // ✅ FIX: Thêm categoryId vào exerciseId để tránh trùng lặp
        final exerciseId = '${categoryId}_${_slugify(exercise['title'])}';

        try {
          final itemDoc = catDoc.collection('items').doc(exerciseId);
          final itemSnapshot = await _safeGet(itemDoc);

          if (!itemSnapshot.exists) {
            await itemDoc.set({
              'id': exerciseId,
              'category': categoryId,
              'title': exercise['title'],
              'description': exercise['description'],
              'durationSeconds': exercise['durationSeconds'],
              'imageUrl': exercise['imageUrl'],
              'difficulty': exercise['difficulty'],
              'calories': exercise['calories'] ?? 0,
              'sets': exercise['sets'],
              'reps': exercise['reps'],
              'createdAt': FieldValue.serverTimestamp(),
            });

            debugPrint("   ➕ Added exercise: ${exercise['title']}");
          } else {
            debugPrint("   ➖ Exercise exists: ${exercise['title']} (skip)");
          }

          // Small delay between writes to avoid rate limiting
          if (i < items.length - 1) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
        } catch (e) {
          debugPrint("   ⚠️ Failed to add ${exercise['title']}: $e");
        }
      }
    } catch (e) {
      debugPrint("⚠️ Category $categoryId failed: $e");
    }
  }
}

/// ---------------------------------------------------------
/// 4) Seed Workout Plan (with retry)
/// ---------------------------------------------------------
Future<void> _seedWorkoutPlan(FirebaseFirestore firestore, String uid) async {
  try {
    final query = firestore
        .collection('plans')
        .where('userId', isEqualTo: uid)
        .limit(1);

    final existing = await _safeQuery(query);

    if (existing.docs.isNotEmpty) {
      debugPrint("➖ Workout plan exists (skip)");
      return;
    }

    final categoriesSnapshot = await _safeQuery(
        firestore.collection('exercise_categories')
    );

    List<Map<String, dynamic>> exercises = [];

    for (final cat in categoriesSnapshot.docs) {
      try {
        final itemsSnapshot = await _safeQuery(
            cat.reference.collection('items').limit(1)
        );

        if (itemsSnapshot.docs.isNotEmpty) {
          final e = itemsSnapshot.docs.first;

          exercises.add({
            'exerciseId': e.id,  // ✅ Dùng e.id thay vì e['id']
            'title': e['title'],
            'durationSeconds': e['durationSeconds'],
            'calories': e['calories'],
          });
        }
      } catch (e) {
        debugPrint("⚠️ Failed to get items for category: $e");
      }
    }

    if (exercises.isNotEmpty) {
      await firestore.collection('plans').add({
        'userId': uid,
        'title': 'Starter Workout Plan',
        'exercises': exercises.take(4).toList(),
        'date': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Workout plan created");
    }
  } catch (e) {
    debugPrint("⚠️ Workout plan seed failed: $e");
  }
}

/// ---------------------------------------------------------
/// 5) Seed Workout Log
/// ---------------------------------------------------------
Future<void> _seedWorkoutLog(FirebaseFirestore firestore, String uid) async {
  try {
    final query = firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: uid)
        .limit(1);

    final existing = await _safeQuery(query);

    if (existing.docs.isNotEmpty) {
      debugPrint("➖ Workout log exists (skip)");
      return;
    }

    await firestore.collection('workout_logs').add({
      'userId': uid,
      'date': DateTime.now().toIso8601String(),
      'totalCalories': 120,
      'totalDuration': 600,
      'completedExercises': [
        {
          'exerciseId': 'abs_crunches',
          'title': 'Crunches',
          'durationSeconds': 180,
          'calories': 8,
          'timestamp': DateTime.now().toIso8601String(),
        }
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint("✅ Workout log created");
  } catch (e) {
    debugPrint("⚠️ Workout log seed failed: $e");
  }
}

/// ---------------------------------------------------------
/// Helper: Safe slug generator
/// ---------------------------------------------------------
String _slugify(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

/// ---------------------------------------------------------
/// Helper: Generate consistent exercise images (FIXED)
/// ---------------------------------------------------------
String _getExerciseImage(String exerciseName) {
  final seed = exerciseName.hashCode.abs();
  // ✅ FIX: Dùng Unsplash thay vì placeholder - ảnh thật và ổn định
  return 'https://source.unsplash.com/400x300/?fitness,exercise,workout&sig=$seed';
}

/// ---------------------------------------------------------
/// Helper: TimeoutException
/// ---------------------------------------------------------
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

/// --------------------------------------------------------
/// DATA SOURCE: Bài tập mẫu - ĐÃ XÓA TRÙNG LẶP
/// --------------------------------------------------------
Map<String, List<Map<String, dynamic>>> _exerciseData() {
  return {
    'abs': [
      {
        'title': 'Crunches',
        'description': 'Classic abdominal exercise focusing on core strength.',
        'durationSeconds': 180,
        'imageUrl': _getExerciseImage('Crunches'),
        'difficulty': 'easy',
        'calories': 8,
        'sets': 3,
        'reps': 20,
      },
      {
        'title': 'Plank',
        'description': 'Hold your body straight using core muscles to build stability.',
        'durationSeconds': 60,
        'imageUrl': _getExerciseImage('Plank'),
        'difficulty': 'medium',
        'calories': 5,
        'sets': 3,
        'reps': 1,
      },
      {
        'title': 'Leg Raises',
        'description': 'Lie flat on your back and lift your legs to strengthen lower abs.',
        'durationSeconds': 120,
        'imageUrl': _getExerciseImage('Leg Raises'),
        'difficulty': 'medium',
        'calories': 7,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Russian Twist',
        'description': 'Sit and twist your torso from side to side to train obliques and improve core balance.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Russian Twist'),
        'difficulty': 'medium',
        'calories': 6,
        'sets': 3,
        'reps': 20,
      },
      {
        'title': 'Bicycle Crunches',
        'description': 'Alternate touching your elbows to opposite knees to engage the full core.',
        'durationSeconds': 150,
        'imageUrl': _getExerciseImage('Bicycle Crunches'),
        'difficulty': 'medium',
        'calories': 9,
        'sets': 3,
        'reps': 25,
      },
      {
        'title': 'Mountain Climbers',
        'description': 'Perform fast alternating knee drives to build endurance and core strength.',
        'durationSeconds': 90,
        'imageUrl': _getExerciseImage('Mountain Climbers'),
        'difficulty': 'hard',
        'calories': 12,
        'sets': 3,
        'reps': 30,
      },
      {
        'title': 'Flutter Kicks',
        'description': 'Lie flat and alternate kicking your legs – great for lower abs.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Flutter Kicks'),
        'difficulty': 'medium',
        'calories': 8,
        'sets': 3,
        'reps': 25,
      },
    ],
    'legs': [
      {
        'title': 'Squats',
        'description': 'Classic lower body exercise that strengthens legs and glutes.',
        'durationSeconds': 120,
        'imageUrl': _getExerciseImage('Squats'),
        'difficulty': 'medium',
        'calories': 10,
        'sets': 4,
        'reps': 15,
      },
      {
        'title': 'Lunges',
        'description': 'Step forward and lower your hips — great for balance and leg strength.',
        'durationSeconds': 150,
        'imageUrl': _getExerciseImage('Lunges'),
        'difficulty': 'medium',
        'calories': 12,
        'sets': 3,
        'reps': 12,
      },
      {
        'title': 'Calf Raises',
        'description': 'Raise your heels off the ground to train calves.',
        'durationSeconds': 90,
        'imageUrl': _getExerciseImage('Calf Raises'),
        'difficulty': 'easy',
        'calories': 6,
        'sets': 4,
        'reps': 20,
      },
      {
        'title': 'Wall Sit',
        'description': 'Hold a seated position against a wall to build endurance.',
        'durationSeconds': 60,
        'imageUrl': _getExerciseImage('Wall Sit'),
        'difficulty': 'hard',
        'calories': 8,
        'sets': 3,
        'reps': 1,
      },
      {
        'title': 'Jump Squats',
        'description': 'Explosive squat movement for power and legs conditioning.',
        'durationSeconds': 80,
        'imageUrl': _getExerciseImage('Jump Squats'),
        'difficulty': 'hard',
        'calories': 15,
        'sets': 3,
        'reps': 12,
      },
    ],
    'shoulder': [
      {
        'title': 'Shoulder Press',
        'description': 'Push weights or arms overhead to strengthen deltoids.',
        'durationSeconds': 120,
        'imageUrl': _getExerciseImage('Shoulder Press'),
        'difficulty': 'medium',
        'calories': 10,
        'sets': 3,
        'reps': 12,
      },
      {
        'title': 'Lateral Raises',
        'description': 'Raise arms to the side — targets lateral deltoids.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Lateral Raises'),
        'difficulty': 'medium',
        'calories': 8,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Front Raises',
        'description': 'Lift arms forward to strengthen front deltoids.',
        'durationSeconds': 90,
        'imageUrl': _getExerciseImage('Front Raises'),
        'difficulty': 'easy',
        'calories': 7,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Pike Push-Ups',
        'description': 'Bodyweight overhead press alternative to train shoulders.',
        'durationSeconds': 60,
        'imageUrl': _getExerciseImage('Pike Push-Ups'),
        'difficulty': 'hard',
        'calories': 12,
        'sets': 3,
        'reps': 10,
      },
    ],
    // ✅ ARM: Đã xóa Push-Ups và Diamond Push-Ups vì trùng với chest/upperbody
    'arm': [
      {
        'title': 'Tricep Dips',
        'description': 'Use a chair or bench to train triceps.',
        'durationSeconds': 90,
        'imageUrl': _getExerciseImage('Tricep Dips'),
        'difficulty': 'medium',
        'calories': 9,
        'sets': 3,
        'reps': 12,
      },
      {
        'title': 'Bicep Curls',
        'description': 'Lift weights to strengthen biceps.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Bicep Curls'),
        'difficulty': 'easy',
        'calories': 7,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Hammer Curls',
        'description': 'Curl with neutral grip to target brachialis and forearms.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Hammer Curls'),
        'difficulty': 'easy',
        'calories': 7,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Overhead Tricep Extension',
        'description': 'Extend arms overhead to isolate triceps.',
        'durationSeconds': 90,
        'imageUrl': _getExerciseImage('Overhead Tricep Extension'),
        'difficulty': 'medium',
        'calories': 8,
        'sets': 3,
        'reps': 12,
      },
    ],
    'chest': [
      {
        'title': 'Push-Ups',
        'description': 'Classic bodyweight exercise for chest, shoulders, and triceps.',
        'durationSeconds': 120,
        'imageUrl': _getExerciseImage('Push-Ups'),
        'difficulty': 'medium',
        'calories': 12,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Wide Push-Ups',
        'description': 'Wide hand placement to increase chest activation.',
        'durationSeconds': 120,
        'imageUrl': _getExerciseImage('Wide Push-Ups'),
        'difficulty': 'medium',
        'calories': 12,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Diamond Push-Ups',
        'description': 'Close-grip push-ups that heavily target triceps and inner chest.',
        'durationSeconds': 80,
        'imageUrl': _getExerciseImage('Diamond Push-Ups'),
        'difficulty': 'hard',
        'calories': 14,
        'sets': 3,
        'reps': 10,
      },
      {
        'title': 'Chest Fly (Floor)',
        'description': 'Open and close arms like hugging motion.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Chest Fly'),
        'difficulty': 'easy',
        'calories': 7,
        'sets': 3,
        'reps': 12,
      },
      {
        'title': 'Incline Push-Ups',
        'description': 'Push-ups on elevated surface to target upper chest.',
        'durationSeconds': 90,
        'imageUrl': _getExerciseImage('Incline Push-Ups'),
        'difficulty': 'easy',
        'calories': 6,
        'sets': 3,
        'reps': 12,
      },
    ],
    'back': [
      {
        'title': 'Superman',
        'description': 'Lift arms and legs off the floor to strengthen lower back.',
        'durationSeconds': 80,
        'imageUrl': _getExerciseImage('Superman'),
        'difficulty': 'easy',
        'calories': 5,
        'sets': 3,
        'reps': 12,
      },
      {
        'title': 'Reverse Snow Angels',
        'description': 'Move arms in arcs while lying face down.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Reverse Snow Angels'),
        'difficulty': 'medium',
        'calories': 7,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Bird Dog',
        'description': 'Extend opposite arm and leg to improve stability.',
        'durationSeconds': 120,
        'imageUrl': _getExerciseImage('Bird Dog'),
        'difficulty': 'medium',
        'calories': 6,
        'sets': 3,
        'reps': 12,
      },
    ],
    'butt': [
      {
        'title': 'Glute Bridge',
        'description': 'Lift hips to activate glutes.',
        'durationSeconds': 120,
        'imageUrl': _getExerciseImage('Glute Bridge'),
        'difficulty': 'easy',
        'calories': 7,
        'sets': 3,
        'reps': 15,
      },
      {
        'title': 'Donkey Kicks',
        'description': 'Kick one leg upward to build glute strength.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Donkey Kicks'),
        'difficulty': 'easy',
        'calories': 6,
        'sets': 3,
        'reps': 20,
      },
      {
        'title': 'Fire Hydrant',
        'description': 'Lift knee sideways to train outer glutes.',
        'durationSeconds': 90,
        'imageUrl': _getExerciseImage('Fire Hydrant'),
        'difficulty': 'medium',
        'calories': 7,
        'sets': 3,
        'reps': 15,
      },
    ],
    'warmup': [
      {
        'title': 'Jumping Jacks',
        'description': 'Full body warmup raising heart rate.',
        'durationSeconds': 60,
        'imageUrl': _getExerciseImage('Jumping Jacks'),
        'difficulty': 'easy',
        'calories': 8,
        'sets': 1,
        'reps': 1,
      },
      {
        'title': 'Arm Circles',
        'description': 'Rotate arms to loosen shoulder joints.',
        'durationSeconds': 60,
        'imageUrl': _getExerciseImage('Arm Circles'),
        'difficulty': 'easy',
        'calories': 4,
        'sets': 1,
        'reps': 1,
      },
      {
        'title': 'High Knees',
        'description': 'Run in place lifting knees high.',
        'durationSeconds': 60,
        'imageUrl': _getExerciseImage('High Knees'),
        'difficulty': 'medium',
        'calories': 10,
        'sets': 1,
        'reps': 1,
      },
    ],
    // ✅ UPPERBODY: Đã xóa Push-Ups vì trùng với chest
    'upperbody': [
      {
        'title': 'Plank Shoulder Tap',
        'description': 'Tap shoulders while maintaining plank position.',
        'durationSeconds': 90,
        'imageUrl': _getExerciseImage('Plank Shoulder Tap'),
        'difficulty': 'medium',
        'calories': 8,
        'sets': 3,
        'reps': 20,
      },
      {
        'title': 'Decline Push-Ups',
        'description': 'Feet elevated push-ups for advanced upper body strength.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Decline Push-Ups'),
        'difficulty': 'hard',
        'calories': 14,
        'sets': 3,
        'reps': 12,
      },
      {
        'title': 'Arm Haulers',
        'description': 'Lying face down, move arms in swimming motion.',
        'durationSeconds': 80,
        'imageUrl': _getExerciseImage('Arm Haulers'),
        'difficulty': 'medium',
        'calories': 7,
        'sets': 3,
        'reps': 15,
      },
    ],
    // ✅ LOWERBODY: Đã xóa Squats và Glute Bridge vì trùng với legs/butt
    'lowerbody': [
      {
        'title': 'Bulgarian Split Squat',
        'description': 'Single leg squat with rear foot elevated.',
        'durationSeconds': 120,
        'imageUrl': _getExerciseImage('Bulgarian Split Squat'),
        'difficulty': 'hard',
        'calories': 12,
        'sets': 3,
        'reps': 10,
      },
      {
        'title': 'Side Lunges',
        'description': 'Step to the side and lower down to train inner thighs.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Side Lunges'),
        'difficulty': 'medium',
        'calories': 10,
        'sets': 3,
        'reps': 12,
      },
      {
        'title': 'Single Leg Deadlift',
        'description': 'Balance on one leg while hinging forward.',
        'durationSeconds': 100,
        'imageUrl': _getExerciseImage('Single Leg Deadlift'),
        'difficulty': 'hard',
        'calories': 11,
        'sets': 3,
        'reps': 10,
      },
    ],
  };
}