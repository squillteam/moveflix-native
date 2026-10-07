import 'package:flutter/material.dart';
import 'package:moveflix/core/domain/models/body_sex.dart';

class SexInputPage extends StatelessWidget {
  final BodySex value;
  final void Function(BodySex)? onSexChanged;

  const SexInputPage({
    super.key,
    required this.value,
    this.onSexChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            onSelectionChanged: (s) => onSexChanged?.call(s.first),
          ),
        ],
      ),
    );
  }
}