import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moveflix/core/domain/models/body_sex.dart';
import 'package:moveflix/core/domain/models/user.dart';
import 'package:moveflix/features/profile/presentation/register_viewmodel.dart';
import 'package:moveflix/features/profile/presentation/widget/sex_input_page.dart';
import 'package:moveflix/features/profile/presentation/widget/text_input_page.dart';
import 'package:moveflix/features/workout/workout_routes.dart';

class RegisterWidget extends StatefulWidget {
  static const routeName = '/register';

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
  final _pageController = PageController();
  int _currentPage = 0;

  RegisterViewModel get viewModel => widget.viewModel;

  final BodySex _sex = BodySex.male;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  List<(Widget, bool Function())> get pages => [
        (
          InputPage(
            controller: _nameController,
            label: "What your name?",
            hintText: "Type here",
            onChanged: viewModel.onNameChanged,
            validator: (_) {
              if (viewModel.state.isNameValid) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          () => viewModel.state.isNameValid,
        ),
        (
          InputPage(
            controller: _birthdayController,
            label: "What your birthday?",
            hintText: "Type here",
            type: TextInputType.datetime,
            onChanged: viewModel.onBirthdateChanged,
            inputFormatters: [BirthdateInputFormatter()],
          ),
          () => viewModel.state.isBirthdateValid,
        ),
        (
          InputPage(
            controller: _heightController,
            label: "What your height?",
            hintText: "Type here",
            type: TextInputType.number,
            onChanged: viewModel.onHeightChanged,
            inputFormatters: [HeightInputFormatter()],
          ),
          () => false
        ),
        (
          InputPage(
            controller: _weightController,
            label: "What your weight?",
            hintText: "Type here",
            type: TextInputType.number,
            onChanged: viewModel.onWeightChanged,
            inputFormatters: [WeightInputFormatter()],
          ),
          () => false,
        ),
        (
          SexInputPage(
            value: viewModel.state.sex,
            onSexChanged: viewModel.onSexChanged,
          ),
          () => false,
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
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: Theme.of(context)
                          .inputDecorationTheme
                          .copyWith(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            border: InputBorder.none,
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withAlpha(128),
                            ),
                          ),
                    ),
                    child: ListenableBuilder(
                        listenable: viewModel,
                        builder: (_, __) => PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              children: pages.map((page) => page.$1).toList(),
                            )),
                  ),
                ),

                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(8),
                //     color: Theme.of(context).colorScheme.surface,
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.only(top: 24, bottom: 12),
                //         child: FieldText(
                //           controller: _nameController,
                //           label: 'What your name?',
                //           hintText: 'Ex: David Gaspar',
                //           textCapitalization: TextCapitalization.words,
                //           validator: (v) =>
                //               (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                //         ),
                //       ),
                //       Divider(height: 1, color: Colors.grey.withAlpha(100), thickness: 1),
                //       Padding(
                //         padding: const EdgeInsets.only(top: 24, bottom: 12),
                //         child: _BirthdayField(
                //           key: _birthdayKey,
                //           validator: (v) => v == null
                //               ? 'Selecione sua data de nascimento'
                //               : null,
                //         ),
                //       ),
                //       Divider(height: 1, color: Colors.grey.withAlpha(100), thickness: 1),
                //       Padding(
                //         padding: const EdgeInsets.only(top: 24, bottom: 12),
                //         child: Row(
                //           children: [
                //             Expanded(
                //               child: FieldText(
                //                 controller: _weightController,
                //                 label: 'Peso (kg)',
                //                 hintText: 'Ex: 70.5',
                //                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
                //                 validator: (v) {
                //                   final n = double.tryParse(v?.trim() ?? '');
                //                   return (n == null || n <= 0) ? 'Informe um peso válido' : null;
                //                 },
                //               ),
                //             ),
                //             VerticalDivider(
                //               width: 1,
                //               color: Colors.grey.withAlpha(100),
                //               thickness: 1,
                //             ),
                //             Expanded(
                //               child: FieldText(
                //                 controller: _heightController,
                //                 label: 'Altura (cm)',
                //                 hintText: 'Ex: 175',
                //                 keyboardType: TextInputType.number,
                //                 validator: (v) {
                //                   final n = double.tryParse(v?.trim() ?? '');
                //                   return (n == null || n <= 0) ? 'Informe uma altura válida' : null;
                //                 },
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //       Divider(height: 1, color: Colors.grey.withAlpha(100), thickness: 1),
                //       Padding(
                //         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                //         child: _SexSelector(
                //           value: _sex,
                //           onChanged: (sex) => setState(() => _sex = sex),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ListenableBuilder(
                    listenable: viewModel,
                    builder: (_, __) => FilledButton(
                      onPressed: viewModel.isSaving ? null : _submit,
                      child: viewModel.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _currentPage == 3 ? 'Cadastrar' : pages[_currentPage].$2() ? 'Próximo' : 'Aguardando',
                            ),
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
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final birthday =
        _birthdayController.text.trim().split("/").map(int.parse).toList();

    await viewModel.save(UserModel(
      name: _nameController.text.trim(),
      sex: _sex,
      birthday: DateTime(
        birthday[2],
        birthday[1],
        birthday[0],
      ),
      weight: double.parse(_weightController.text.trim()),
      height: double.parse(_heightController.text.trim()),
    ));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(WorkoutRoutes.list);
    }
  }
}

class _SexSelector extends StatelessWidget {
  final BodySex value;
  final ValueChanged<BodySex> onChanged;

  const _SexSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sexo', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        SegmentedButton<BodySex>(
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          expandedInsets: EdgeInsets.zero,
          segments: const [
            ButtonSegment(
                value: BodySex.male,
                label: Text('Masculino'),
                icon: Icon(Icons.male)),
            ButtonSegment(
                value: BodySex.female,
                label: Text('Feminino'),
                icon: Icon(Icons.female)),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}

class _BirthdayField extends FormField<DateTime> {
  _BirthdayField({
    super.key,
    super.validator,
  }) : super(
          builder: (FormFieldState<DateTime> state) {
            final formatted = state.value == null
                ? null
                : '${state.value!.day.toString().padLeft(2, '0')}/'
                    '${state.value!.month.toString().padLeft(2, '0')}/'
                    '${state.value!.year}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: state.context,
                      initialDate: state.value ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) state.didChange(picked);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    isEmpty: state.value == null,
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding:
                          EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 0),
                      suffixIcon: Icon(Icons.calendar_today, size: 18),
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    child: Text(
                      formatted ?? 'Ex: 16/02/1999',
                      style:
                          Theme.of(state.context).textTheme.bodyLarge?.copyWith(
                                color: state.value == null
                                    ? Colors.black.withAlpha(80)
                                    : null,
                              ),
                    ),
                  ),
                ),
                if (state.hasError)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(state.context).colorScheme.error,
                        fontSize: 12,
                        height: -0.1,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}
