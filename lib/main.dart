import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moveflix/app/databases/hive.dart';
import 'package:moveflix/app/locator.dart';
import 'package:moveflix/core/data/datasources/user_local_datasource.dart';
import 'package:moveflix/core/data/repositories/user_repository_impl.dart';
import 'package:moveflix/core/domain/repositories/user_repository.dart';
import 'package:moveflix/features/body_map/body_map_module.dart';
import 'package:moveflix/features/body_map/domain/repositories/body_map_repository.dart';
import 'package:moveflix/features/body_map/presentation/body_map_viewmodel.dart';
import 'package:moveflix/features/body_map/presentation/body_map_widget.dart';
import 'package:moveflix/features/profile/profile_module.dart';
import 'package:moveflix/features/profile/profile_routes.dart';
import 'package:moveflix/features/video/data/datasources/video_network_datasource.dart';
import 'package:moveflix/features/video/data/repositories/video_repository_impl.dart';
import 'package:moveflix/features/video/domain/repositories/video_repository.dart';
import 'package:moveflix/features/video/presentation/video_viewmodel.dart';
import 'package:moveflix/features/video/presentation/video_widget.dart';
import 'package:moveflix/app/router/route_observer.dart';
import 'package:moveflix/features/workout/workout_module.dart';
import 'package:moveflix/features/workout/workout_routes.dart';
import 'package:moveflix/shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase().initilize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  _registerDependencies();

  final hasUser = await ServiceLocator.get<UserRepository>().hasUser();
  final initialRoute = hasUser ? WorkoutRoutes.list : ProfileRoutes.save;

  runApp(MyApp(initialRoute: initialRoute));
}

void _registerDependencies() {
  ServiceLocator.register<UserRepository>(
    UserRepositoryImpl(UserLocalDatasource()),
  );
  WorkoutModule.register();
  ServiceLocator.register<VideoRepository>(
    VideoRepositoryImpl(VideoNetworkDatasource()),
  );
  BodyMapModule.register();
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerFlix',
      theme: AppTheme.light,
      initialRoute: initialRoute,
      navigatorObservers: [appRouteObserver],
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: child!,
        );
      },
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case ProfileRoutes.save:
            ProfileModule.register();
            return MaterialPageRoute(
              settings: settings,
              builder: ProfileModule.routes[ProfileRoutes.save]!,
            );

          case VideoWidget.routeName:
            final link = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => VideoWidget(
                viewModel: VideoViewModel(
                  link: link,
                  repository: ServiceLocator.get<VideoRepository>(),
                ),
              ),
            );

          case BodyMapWidget.routeName:
            final bodyMapViewModel = BodyMapViewModel(
              ServiceLocator.get<BodyMapRepository>(),
            );
            WorkoutModule.computeRegionStress()
                .then(bodyMapViewModel.applyStress);
            return MaterialPageRoute(
              builder: (_) => BodyMapWidget(viewModel: bodyMapViewModel),
            );

          default:
            final builder = WorkoutModule.routes[settings.name];
            if (builder == null) return null;
            return MaterialPageRoute(settings: settings, builder: builder);
        }
      },
    );
  }
}
