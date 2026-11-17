import 'package:flutter/material.dart';

class ProgressButton extends StatelessWidget {
  final bool isLoading;
  final bool canProceed;
  final bool isLastStep;
  final VoidCallback onClick;

  const ProgressButton({
    super.key,
    required this.isLoading,
    required this.canProceed,
    required this.isLastStep,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading || !canProceed ? null : onClick,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              isLastStep
                  ? 'Entrar'
                  : canProceed
                      ? 'Próximo'
                      : 'Aguardando campo ser preenchido',
            ),
    );
  }
}
