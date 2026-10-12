import 'package:flutter_test/flutter_test.dart';
import 'package:moveflix/core/domain/models/body_sex.dart';
import 'package:moveflix/core/domain/models/user.dart';
import 'package:moveflix/core/domain/repositories/user_repository.dart';
import 'package:moveflix/features/profile/domain/usecases/save_user_use_case.dart';
import 'package:moveflix/features/profile/presentation/register_viewmodel.dart';

class _FakeUserRepository implements UserRepository {
  UserModel? saved;
  bool shouldThrow = false;

  @override
  Future<UserModel> getUser() async {
    if (saved == null) throw Exception('no user');
    return saved!;
  }

  @override
  Future<bool> hasUser() async => saved != null;

  @override
  Future<void> saveUser(UserModel user) async {
    if (shouldThrow) throw Exception('storage failure');
    saved = user;
  }
}

RegisterViewModel _buildViewModel(UserRepository repo) {
  return RegisterViewModel(
    saveUserUseCase: SaveUserUseCase(userRepository: repo),
  );
}

void _fillValidData(RegisterViewModel vm) {
  vm.onNameChanged('David Gaspar');
  vm.onBirthdateChanged('16/02/1999');
  vm.onHeightChanged('175 cm');
  vm.onWeightChanged('80 kg');
  vm.onSexChanged(BodySex.male);
}

void main() {
  group('RegisterViewModel', () {
    test('isSaving starts as false', () {
      final vm = _buildViewModel(_FakeUserRepository());
      expect(vm.isSaving, isFalse);
    });

    test('register calls repository saveUser with the given user', () async {
      final repo = _FakeUserRepository();
      final vm = _buildViewModel(repo);
      _fillValidData(vm);

      await vm.register();

      expect(repo.saved, isNotNull);
      expect(repo.saved!.name, 'David Gaspar');
      expect(repo.saved!.height, 175);
      expect(repo.saved!.weight, 80.0);
    });

    test('isSaving is false after a successful register', () async {
      final vm = _buildViewModel(_FakeUserRepository());
      _fillValidData(vm);

      await vm.register();

      expect(vm.isSaving, isFalse);
    });

    test('isSaved is true after a successful register', () async {
      final vm = _buildViewModel(_FakeUserRepository());
      _fillValidData(vm);

      await vm.register();

      expect(vm.state.isSaved, isTrue);
    });

    test('isSaving is false after register throws (finally resets state)',
        () async {
      final repo = _FakeUserRepository()..shouldThrow = true;
      final vm = _buildViewModel(repo);
      _fillValidData(vm);

      await vm.register();

      expect(vm.isSaving, isFalse);
    });

    test('isSaved is false after register throws', () async {
      final repo = _FakeUserRepository()..shouldThrow = true;
      final vm = _buildViewModel(repo);
      _fillValidData(vm);

      await vm.register();

      expect(vm.state.isSaved, isFalse);
    });

    test('notifyListeners called at start and end of register', () async {
      final vm = _buildViewModel(_FakeUserRepository());
      _fillValidData(vm);
      final notifyLog = <bool>[];
      vm.addListener(() => notifyLog.add(vm.isSaving));

      await vm.register();

      expect(notifyLog, [true, false]);
    });

    test('notifyListeners called at start and end even when register throws',
        () async {
      final repo = _FakeUserRepository()..shouldThrow = true;
      final vm = _buildViewModel(repo);
      _fillValidData(vm);
      final notifyLog = <bool>[];
      vm.addListener(() => notifyLog.add(vm.isSaving));

      await vm.register();

      expect(notifyLog, [true, false]);
    });
  });
}
