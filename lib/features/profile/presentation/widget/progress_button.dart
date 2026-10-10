import 'package:flutter/material.dart';

class ProgressButton extends StatelessWidget {
  final bool isLoading;
  final int currentStep;
  final List<(Widget, bool Function())> steps;
  final VoidCallback onClick;

  const ProgressButton({
    super.key,
    required this.isLoading,
    required this.currentStep,
    required this.steps,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    bool canProceed = steps[currentStep].$2();

    return FilledButton(
      onPressed: isLoading || !canProceed ? null : onClick,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              currentStep == steps.length - 1
                  ? 'Entrar'
                  : canProceed
                      ? 'Próximo'
                      : 'Aguardando campo ser preenchido',
            ),
    );
  }
}
