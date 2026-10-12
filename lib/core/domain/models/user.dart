import 'dart:convert';

import 'package:moveflix/core/domain/model.dart';
import 'package:moveflix/core/domain/models/body_sex.dart';

class UserModel extends Model {
  final String name;
  final BodySex sex;
  final DateTime birthday;
  final double weight;
  final int height;

  const UserModel({
    required this.name,
    required this.sex,
    required this.birthday,
    required this.weight,
    required this.height,
  });

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      sex: BodySex.values.firstWhere((e) => e.name == map['sex']),
      birthday: DateTime.fromMillisecondsSinceEpoch(map['birthday'] as int),
      weight: (map['weight'] as num).toDouble(),
      height: (map['height'] as num).toInt(),
    );
  }

  UserModel copyWith({
    String? name,
    BodySex? sex,
    DateTime? birthday,
    double? weight,
    int? height,
  }) =>
      UserModel(
        name: name ?? this.name,
        sex: sex ?? this.sex,
        birthday: birthday ?? this.birthday,
        weight: weight ?? this.weight,
        height: height ?? this.height,
      );

  @override
  Map<String, dynamic> toMap() => {
        'name': name,
        'sex': sex.name,
        'birthday': birthday.millisecondsSinceEpoch,
        'weight': weight,
        'height': height,
      };

  @override
  String toJson() => jsonEncode(toMap());
}
