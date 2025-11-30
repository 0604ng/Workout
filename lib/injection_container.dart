// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Data Sources
import 'data/datasources/firestore_exercise_datasource.dart';
import 'data/datasources/firestore_plan_datasource.dart';
import 'data/datasources/firestore_workout_log_datasource.dart';

// Repositories impl
import 'data/repositories_impl/exercise_repository_impl.dart';
import 'data/repositories_impl/plan_repository_impl.dart';
import 'data/repositories_impl/workout_log_repository_impl.dart';

// Domain layer
import 'domain/repositories/exercise_repository.dart';
import 'domain/repositories/plan_repository.dart';
import 'domain/repositories/workout_log_repository.dart';

// Usecases
import 'domain/usecases/create_workout_log_usecase.dart';
import 'domain/usecases/get_user_workout_logs_usecase.dart';

// Providers
import 'presentation/state/auth_provider.dart' as local;
import 'presentation/state/workout_session_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Firebase singletons
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Exercise Repo
  sl.registerLazySingleton<ExerciseRepository>(() {
    final datasource = FirestoreExerciseDatasource(
      firestore: sl<FirebaseFirestore>(),
    );
    return ExerciseRepositoryImpl(datasource: datasource);
  });

  // Plan Repo
  sl.registerLazySingleton<PlanRepository>(() {
    final datasource = FirestorePlanDatasource(
      sl<FirebaseFirestore>(),
    );
    return PlanRepositoryImpl(datasource);
  });

  // Workout Logs Repo (datasource -> repo)
  sl.registerLazySingleton<WorkoutLogRepository>(() {
    final datasource = FirestoreWorkoutLogDatasource(
      sl<FirebaseFirestore>(),
    );
    return WorkoutLogRepositoryImpl(datasource);
  });

  // Usecases
  sl.registerLazySingleton(() => CreateWorkoutLogUseCase(sl<WorkoutLogRepository>()));
  sl.registerLazySingleton(() => GetUserWorkoutLogsUseCase(sl<WorkoutLogRepository>()));

  // AuthProvider
  sl.registerLazySingleton<local.AuthProvider>(() => local.AuthProvider());

  // WorkoutSessionProvider factory: new instance mỗi lần
  sl.registerFactoryParam<WorkoutSessionProvider, String, void>(
        (userId, _) => WorkoutSessionProvider(
      createWorkoutLogUseCase: sl<CreateWorkoutLogUseCase>(),
      userId: userId,
      authProvider: sl<local.AuthProvider>(), // NOT NULL
    ),
  );

}
