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

UserModel _user() => UserModel(
      name: 'David',
      sex: BodySex.male,
      birthday: DateTime(1999, 2, 16),
      weight: 80.0,
      height: 175.0,
    );

void main() {
  group('RegisterViewModel', () {
    test('isSaving starts as false', () {
      final vm = RegisterViewModel(
          saveUserUseCase:
              SaveUserUseCase(userRepository: _FakeUserRepository()));
      expect(vm.isSaving, isFalse);
    });

    test('save calls repository saveUser with the given user', () async {
      final repo = _FakeUserRepository();
      final vm = RegisterViewModel(
          saveUserUseCase: SaveUserUseCase(userRepository: repo));
      final user = _user();

      await vm.save(user);

      expect(repo.saved, isNotNull);
      expect(repo.saved!.name, 'David');
      expect(repo.saved!.weight, 80.0);
    });

    test('isSaving is false after successful save', () async {
      final vm = RegisterViewModel(
          saveUserUseCase:
              SaveUserUseCase(userRepository: _FakeUserRepository()));
      await vm.save(_user());
      expect(vm.isSaving, isFalse);
    });

    test('isSaving is false after save throws (finally resets state)',
        () async {
      final repo = _FakeUserRepository()..shouldThrow = true;
      final vm = RegisterViewModel(
          saveUserUseCase: SaveUserUseCase(userRepository: repo));

      await vm.save(_user());

      expect(vm.isSaving, isFalse);
    });

    test('notifyListeners called at start and end of save', () async {
      final vm = RegisterViewModel(
          saveUserUseCase:
              SaveUserUseCase(userRepository: _FakeUserRepository()));
      final notifyLog = <bool>[];
      vm.addListener(() => notifyLog.add(vm.isSaving));

      await vm.save(_user());

      expect(notifyLog, [true, false]);
    });

    test('notifyListeners called at start and end even when save throws',
        () async {
      final repo = _FakeUserRepository()..shouldThrow = true;
      final vm = RegisterViewModel(
          saveUserUseCase: SaveUserUseCase(userRepository: repo));
      final notifyLog = <bool>[];
      vm.addListener(() => notifyLog.add(vm.isSaving));

      await vm.save(_user());

      expect(notifyLog, [true, false]);
    });
  });
}
