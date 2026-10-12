import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:moveflix/app/databases/hive_adapter.dart';
import 'package:moveflix/app/locator.dart';
import 'package:moveflix/core/domain/models/user.dart';
import 'package:moveflix/core/domain/repositories/user_repository.dart';
import 'package:moveflix/features/profile/profile_routes.dart';
import 'package:moveflix/features/workout/domain/models/workout_plan.dart';
import 'package:moveflix/features/workout/domain/models/workout_preferences.dart';
import 'package:moveflix/features/workout/domain/repositories/workout_plan_repository.dart';
import 'package:moveflix/features/workout/domain/repositories/workout_preferences_repository.dart';
import 'package:moveflix/main.dart';

class _FakeUserRepository implements UserRepository {
  @override
  Future<UserModel> getUser() => throw Exception('no user');
  @override
  Future<bool> hasUser() async => false;
  @override
  Future<void> saveUser(UserModel user) async {}
}

class _FakeWorkoutPlanRepository implements WorkoutPlanRepository {
  @override
  Future<List<WorkoutPlan>> getWorkouts() async => [];
  @override
  Future<WorkoutPlan> getById(String id) async => throw UnimplementedError();
}

class _FakeWorkoutPreferencesRepository implements WorkoutPreferencesRepository {
  @override
  Future<WorkoutPreferences> getPreferences() async =>
      const WorkoutPreferences();
  @override
  Future<void> savePreferences(WorkoutPreferences prefs) async {}
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test_');
    Hive.init(tempDir.path);
    loadTypeAdapters();
    ServiceLocator.register<UserRepository>(_FakeUserRepository());
    ServiceLocator.register<WorkoutPlanRepository>(_FakeWorkoutPlanRepository());
    ServiceLocator.register<WorkoutPreferencesRepository>(
      _FakeWorkoutPreferencesRepository(),
    );
  });

  tearDownAll(() async {
    ServiceLocator.reset();
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('App smoke test — renders without exception',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: ProfileRoutes.save));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
