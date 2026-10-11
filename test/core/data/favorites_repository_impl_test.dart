import 'package:flutter_test/flutter_test.dart';
import 'package:moveflix/core/data/datasources/user_local_datasource.dart';
import 'package:moveflix/core/data/repositories/user_repository_impl.dart';
import 'package:moveflix/core/domain/models/body_sex.dart';
import 'package:moveflix/core/domain/models/user.dart';

class _FakeUserLocalDatasource implements UserLocalDatasource {
  UserModel? _user;

  @override
  Future<UserModel?> getUser() async => _user;

  @override
  Future<void> saveUser(UserModel user) async => _user = user;
}

UserModel _user({String name = 'David'}) => UserModel(
      name: name,
      sex: BodySex.male,
      birthday: DateTime(1999, 2, 16),
      weight: 80.0,
      height: 175,
    );

void main() {
  group('UserRepositoryImpl', () {
    group('getUser', () {
      test('throws when no user saved', () async {
        final repo = UserRepositoryImpl(_FakeUserLocalDatasource());
        expect(() => repo.getUser(), throwsException);
      });

      test('returns user after save', () async {
        final repo = UserRepositoryImpl(_FakeUserLocalDatasource());
        await repo.saveUser(_user());
        final retrieved = await repo.getUser();
        expect(retrieved.name, 'David');
        expect(retrieved.weight, 80.0);
        expect(retrieved.height, 175);
      });

      test('returns latest user after overwrite', () async {
        final repo = UserRepositoryImpl(_FakeUserLocalDatasource());
        await repo.saveUser(_user(name: 'First'));
        await repo.saveUser(_user(name: 'Second'));
        final user = await repo.getUser();
        expect(user.name, 'Second');
      });
    });

    group('hasUser', () {
      test('returns false when no user saved', () async {
        final repo = UserRepositoryImpl(_FakeUserLocalDatasource());
        expect(await repo.hasUser(), isFalse);
      });

      test('returns true after save', () async {
        final repo = UserRepositoryImpl(_FakeUserLocalDatasource());
        await repo.saveUser(_user());
        expect(await repo.hasUser(), isTrue);
      });
    });
  });
}
