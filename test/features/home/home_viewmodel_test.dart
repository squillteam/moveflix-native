import 'package:flutter_test/flutter_test.dart';
import 'package:moveflix/core/domain/models/user.dart';
import 'package:moveflix/core/domain/models/body_sex.dart';
import 'package:moveflix/core/domain/repositories/user_repository.dart';
import 'package:moveflix/features/workout/domain/models/workout_plan.dart';
import 'package:moveflix/features/workout/domain/models/workout_preferences.dart';
import 'package:moveflix/features/workout/domain/repositories/workout_plan_repository.dart';
import 'package:moveflix/features/workout/domain/repositories/workout_preferences_repository.dart';
import 'package:moveflix/features/workout/domain/usecases/browse_workouts_use_case.dart';
import 'package:moveflix/features/workout/domain/usecases/toggle_favorite_workout_use_case.dart';
import 'package:moveflix/features/workout/presentation/list/workout_list_viewmodel.dart';

class _FakeUserRepository implements UserRepository {
  @override
  Future<UserModel> getUser() async => UserModel(
        name: 'Test',
        sex: BodySex.male,
        birthday: DateTime(1990),
        weight: 70.0,
        height: 170,
      );

  @override
  Future<bool> hasUser() async => true;

  @override
  Future<void> saveUser(UserModel user) async {}
}

class _FakeWorkoutPlanRepository implements WorkoutPlanRepository {
  final List<WorkoutPlan> plans;
  final Object? error;

  _FakeWorkoutPlanRepository({this.plans = const [], this.error});

  @override
  Future<List<WorkoutPlan>> getWorkouts() async {
    if (error != null) throw error!;
    return plans;
  }

  @override
  Future<WorkoutPlan> getById(String id) async =>
      plans.firstWhere((p) => p.id == id);
}

class _FakeWorkoutPreferencesRepository implements WorkoutPreferencesRepository {
  @override
  Future<WorkoutPreferences> getPreferences() async =>
      const WorkoutPreferences();

  @override
  Future<void> savePreferences(WorkoutPreferences prefs) async {}
}

WorkoutPlan _plan(String id, String name) => WorkoutPlan(
      id: id,
      name: name,
      description: 'desc',
      coverUrl: 'https://example.com/$id.jpg',
      levels: const [],
    );

WorkoutListViewModel _vm({List<WorkoutPlan> plans = const [], Object? error}) {
  final workoutRepo = _FakeWorkoutPlanRepository(plans: plans, error: error);
  final prefsRepo = _FakeWorkoutPreferencesRepository();
  return WorkoutListViewModel(
    userRepository: _FakeUserRepository(),
    browseWorkoutsUseCase: BrowseWorkoutsUseCase(
      workoutPlanRepository: workoutRepo,
      preferencesRepository: prefsRepo,
    ),
    workoutPlanRepository: workoutRepo,
    toggleFavoriteWorkoutUseCase: ToggleFavoriteWorkoutUseCase(prefsRepo),
  );
}

void main() {
  group('WorkoutListViewModel', () {
    test('initial state: isLoading=true, empty list, no error', () {
      final vm = _vm(plans: [_plan('p1', 'Leg Day')]);
      expect(vm.isLoading, isTrue);
      expect(vm.workoutCoverList, isEmpty);
      expect(vm.hasError, isFalse);
      expect(vm.error, isNull);
    });

    test('init success: populates cover list, clears error, isLoading=false', () async {
      final vm = _vm(plans: [_plan('plan-1', 'Leg Day')]);
      await vm.init();

      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isFalse);
      expect(vm.workoutCoverList, hasLength(1));
      expect(vm.workoutCoverList.first.id, 'plan-1');
    });

    test('init parses multiple plans correctly', () async {
      final vm = _vm(plans: [_plan('plan-1', 'Leg Day'), _plan('plan-2', 'Arm Day')]);
      await vm.init();

      expect(vm.workoutCoverList, hasLength(2));
      expect(vm.workoutCoverList[0].id, 'plan-1');
      expect(vm.workoutCoverList[1].id, 'plan-2');
    });

    test('init error: sets error, list remains empty, isLoading=false', () async {
      final vm = _vm(error: Exception('asset not found'));
      await vm.init();

      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isTrue);
      expect(vm.error, contains('asset not found'));
      expect(vm.workoutCoverList, isEmpty);
    });

    test('init notifies listeners on success', () async {
      final vm = _vm(plans: [_plan('p1', 'A')]);
      var notifyCount = 0;
      vm.addListener(() => notifyCount++);
      await vm.init();
      expect(notifyCount, 2);
    });

    test('init notifies listeners on error', () async {
      final vm = _vm(error: Exception('fail'));
      var notifyCount = 0;
      vm.addListener(() => notifyCount++);
      await vm.init();
      expect(notifyCount, 2);
    });

    test('init runs asynchronously and updates state', () async {
      final vm = _vm(plans: [_plan('p1', 'A')]);
      final future = vm.init();
      expect(vm.isLoading, isTrue);
      await future;
      expect(vm.isLoading, isFalse);
      expect(vm.workoutCoverList, hasLength(1));
    });
  });
}
