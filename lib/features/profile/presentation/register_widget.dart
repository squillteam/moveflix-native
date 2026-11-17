import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moveflix/features/profile/presentation/register_viewmodel.dart';
import 'package:moveflix/features/profile/presentation/widget/progress_button.dart';
import 'package:moveflix/features/profile/presentation/widget/sex_input_page.dart';
import 'package:moveflix/features/profile/presentation/widget/text_input_page.dart';
import 'package:moveflix/features/workout/workout_routes.dart';

class RegisterWidget extends StatefulWidget {
  final RegisterViewModel viewModel;

  const RegisterWidget({super.key, required this.viewModel});

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _birthdayFocusNode = FocusNode();
  final _heightFocusNode = FocusNode();
  final _weightFocusNode = FocusNode();
  final _pageController = PageController();
  int _currentPage = 0;

  RegisterViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose the controllers
    _nameController.dispose();
    _birthdayController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _pageController.dispose();

    // Dispose the focus nodes
    _nameFocusNode.dispose();
    _birthdayFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();

    viewModel.dispose();

    super.dispose();
  }

  // Cada passo guarda um builder, não o widget pronto: a página é recriada a
  // cada build com o estado atual do ViewModel.
  late final List<_RegisterStep> _steps = [
    _RegisterStep(
      focusNode: _nameFocusNode,
      isValid: () => viewModel.state.isNameValid,
      build: () => TextInputPage(
        controller: _nameController,
        focusNode: _nameFocusNode,
        label: "What your name?",
        hintText: "Type here",
        onChanged: viewModel.onNameChanged,
        validator: (_) {
          if (!viewModel.state.isNameValid) {
            return 'Please enter your name';
          }
          return null;
        },
      ),
    ),
    _RegisterStep(
      focusNode: _birthdayFocusNode,
      isValid: () => viewModel.state.isBirthdateValid,
      build: () => TextInputPage(
        controller: _birthdayController,
        focusNode: _birthdayFocusNode,
        label: "What your birthday?",
        hintText: "Type here",
        type: TextInputType.datetime,
        onChanged: viewModel.onBirthdateChanged,
        inputFormatters: [BirthdateInputFormatter()],
      ),
    ),
    _RegisterStep(
      focusNode: _heightFocusNode,
      isValid: () => viewModel.state.isHeightValid,
      build: () => TextInputPage(
        controller: _heightController,
        focusNode: _heightFocusNode,
        label: "What your height?",
        hintText: "Type here",
        type: TextInputType.number,
        onChanged: viewModel.onHeightChanged,
        inputFormatters: [HeightInputFormatter()],
      ),
    ),
    _RegisterStep(
      focusNode: _weightFocusNode,
      isValid: () => viewModel.state.isWeightValid,
      build: () => TextInputPage(
        controller: _weightController,
        focusNode: _weightFocusNode,
        label: "What your weight?",
        hintText: "Type here",
        type: TextInputType.number,
        onChanged: viewModel.onWeightChanged,
        inputFormatters: [WeightInputFormatter()],
      ),
    ),
    _RegisterStep(
      isValid: () => true,
      build: () => SexInputPage(
        value: viewModel.state.sex,
        onSexChanged: viewModel.onSexChanged,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFD8161),
                const Color(0xFFFF5A5F),
              ]),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: SvgPicture.asset(
                    'assets/image/svg/logo.svg',
                    width: MediaQuery.of(context).size.width * 0.4,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.surface, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha seus dados para começar.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withAlpha(200),
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: viewModel,
                    builder: (_, __) => PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                        _steps[index].focusNode?.requestFocus();
                      },
                      children: _steps.map((step) => step.build()).toList(),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ListenableBuilder(
                    listenable: viewModel,
                    builder: (_, __) => ProgressButton(
                        isLoading: viewModel.isSaving,
                        canProceed: _steps[_currentPage].isValid(),
                        isLastStep: _currentPage == _steps.length - 1,
                        onClick: _submit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    await viewModel.register();

    if (mounted && viewModel.state.isSaved) {
      Navigator.of(context).pushReplacementNamed(WorkoutRoutes.list);
    }
  }
}

class _RegisterStep {
  final Widget Function() build;
  final bool Function() isValid;
  final FocusNode? focusNode;

  const _RegisterStep({
    required this.build,
    required this.isValid,
    this.focusNode,
  });
}
