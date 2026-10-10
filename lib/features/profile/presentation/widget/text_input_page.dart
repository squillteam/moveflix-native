import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextInputPage extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hintText;
  final TextInputType? type;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;

  const TextInputPage({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.onChanged,
    this.hintText,
    this.type,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: type,
        validator: validator,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: InputBorder.none,
          label: Text(
              label
          ),
          // O InputDecorator aplica uma escala extra de 0.75x ao label
          // flutuante (floatingLabelBehavior: always), então o fontSize
          // aqui precisa ser 18 / 0.75 para renderizar visualmente a 18px.
          floatingLabelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white.withAlpha(128),
          ),
        ),
      ),
    );
  }
}

class BirthdateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }

    final text = newValue.text;
    final cleanText = text.replaceAll(RegExp(r'\D'), '');
    if (cleanText.length > 8) {
      return oldValue;
    }

    final buffer = StringBuffer();

    for (int i = 0; i < cleanText.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(cleanText[i]);
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
    );
  }
}

class HeightInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }

    var cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.length > 6 || cleanText.isEmpty) {
      return oldValue;
    }

    final formattedText = cleanText + ' cm';

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cleanText.length),
    );
  }
}

class WeightInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset < oldValue.selection.baseOffset) {
      return newValue;
    }

    var cleanText = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');
    if (cleanText.length > 6 || cleanText.isEmpty) {
      return oldValue;
    }

    final firstComma = cleanText.indexOf(',');
    if (firstComma != -1) {
      cleanText = cleanText.substring(0, firstComma + 1) +
          cleanText.substring(firstComma + 1).replaceAll(',', '');
    }

    final formattedText = cleanText + ' kg';

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cleanText.length),
    );
  }
}
