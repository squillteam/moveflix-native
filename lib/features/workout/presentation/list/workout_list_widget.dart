import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moveflix/app/router/route_observer.dart';
import 'package:moveflix/features/body_map/body_map_routes.dart';
import 'package:moveflix/features/workout/domain/models/workout_plan.dart';
import 'package:moveflix/features/workout/presentation/list/widget/header.dart';
import 'package:moveflix/features/workout/presentation/list/widget/menu.dart';
import 'package:moveflix/features/workout/presentation/list/widget/workout_cover_card.dart';
import 'package:moveflix/features/workout/presentation/list/workout_list_viewmodel.dart';
import 'package:moveflix/features/workout/workout_routes.dart';
import 'package:moveflix/shared/widgets/loading.dart';
import 'package:moveflix/shared/widgets/top_drawer.dart';

class WorkoutListWidget extends StatefulWidget {
  final WorkoutListViewModel _viewModel;

  const WorkoutListWidget({super.key, required WorkoutListViewModel viewModel})
      : _viewModel = viewModel;

  @override
  State<WorkoutListWidget> createState() => _WorkoutListWidgetState();
}

class _WorkoutListWidgetState extends State<WorkoutListWidget> with RouteAware {
  WorkoutListViewModel get viewModel => widget._viewModel;
  late final StreamSubscription<WorkoutPlan> navigationEvent;

  static const double _menuHeight = 260;

  @override
  void initState() {
    super.initState();
    viewModel.init();

    navigationEvent = viewModel.navigationEvents.listen((plan) {
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        WorkoutRoutes.detail,
        arguments: plan,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    navigationEvent.cancel();
    viewModel.dispose();
    super.dispose();
  }

  Widget _buildGrid(double topInset) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(height: topInset + Header.height),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: ListenableBuilder(
            listenable: viewModel,
            builder: (BuildContext context, Widget? child) => SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1417 / 2008,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, int index) {
                  final workoutCover = viewModel.workoutCoverList[index];
                  return WorkoutCoverCard(
                    data: workoutCover,
                    onTap: () => viewModel.openWorkoutCover(workoutCover.id),
                    onFavorite: () => viewModel.toggleFavorite(workoutCover.id),
                  );
                },
                childCount: viewModel.workoutCoverList.length,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: TopDrawer(
        menuHeight: _menuHeight,
        footerHeight: Header.height,
        menuBuilder: (_, toggle) => Menu(
          onBodyMapTap: () {
            toggle();
            Navigator.of(context).pushNamed(BodyMapRoutes.map);
          },
        ),
        footerBuilder: (_, toggle, isOpen) => ValueListenableBuilder(
          valueListenable: viewModel.user,
          builder: (context, user, _) => Header(
            onMenuTap: toggle,
            username: user?.name ?? '',
            isOpen: isOpen,
          ),
        ),
        panelColor: Theme.of(context).colorScheme.surface,
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.isLoading) return Loading();
            if (viewModel.hasError) {
              return LoadingError(message: 'Erro ao carregar os treinos.');
            }
            return _buildGrid(topInset);
          },
        ),
      ),
    );
  }

  @override
  void didPopNext() {
    viewModel.init();
  }
}
