import 'package:flutter/material.dart';
import 'package:moveflix/app/locator.dart';
import 'package:moveflix/core/data/datasources/user_local_datasource.dart';
import 'package:moveflix/core/data/repositories/user_repository_impl.dart';
import 'package:moveflix/core/domain/repositories/user_repository.dart';
import 'package:moveflix/features/profile/domain/usecases/save_user_use_case.dart';
import 'package:moveflix/features/profile/presentation/register_viewmodel.dart';
import 'package:moveflix/features/profile/presentation/register_widget.dart';
import 'package:moveflix/features/profile/profile_routes.dart';

class ProfileModule {
  static void register() {
    ServiceLocator.register<UserRepository>(
      UserRepositoryImpl(UserLocalDatasource()),
    );
  }

  static Map<String, WidgetBuilder> get routes => {
    ProfileRoutes.save: (_) {
      return RegisterWidget(
        viewModel: RegisterViewModel(
          saveUserUseCase: SaveUserUseCase(
            userRepository: ServiceLocator.get<UserRepository>(),
          ),
        ),
      );
    }
  };
}