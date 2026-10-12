import 'package:moveflix/core/domain/models/user.dart';
import 'package:moveflix/core/domain/repositories/user_repository.dart';

class SaveUserUseCase {
  final UserRepository _repository;

  SaveUserUseCase({
    required UserRepository userRepository,
  }) : _repository = userRepository;

  Future<void> call(UserModel user) => _repository.saveUser(user);
}
