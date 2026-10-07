import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:moveflix/core/domain/models/body_sex.dart';
import 'package:moveflix/core/domain/models/user.dart';
import 'package:moveflix/features/profile/domain/usecases/save_user_use_case.dart';

class RegisterState {
  final String name;
  final String birthdateText;
  final String heightText;
  final int? height;
  final String weightText;
  final double? weight;
  final BodySex sex;
  final bool isSaved;

  const RegisterState({
    this.name = '',
    this.birthdateText = '',
    this.heightText = '',
    this.height,
    this.weightText = '',
    this.weight,
    this.sex = BodySex.male,
    this.isSaved = false,
  });

  RegisterState copyWith({
    String? name,
    String? birthdateText,
    DateTime? birthdate,
    String? heightText,
    int? height,
    String? weightText,
    double? weight,
    BodySex? sex,
    bool? isSaved,
    List<bool>? isValid,
  }) {
    return RegisterState(
      name: name ?? this.name,
      birthdateText: birthdateText ?? this.birthdateText,
      heightText: heightText ?? this.heightText,
      height: height ?? this.height,
      weightText: weightText ?? this.weightText,
      weight: weight ?? this.weight,
      sex: sex ?? this.sex,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  // Derived states
  bool get isNameValid => name.isNotEmpty && name.split(" ").length >= 2;

  DateTime? get birthdate => parseBirthdate(birthdateText);
  bool get isBirthdateValid => birthdate != null;
}

class RegisterViewModel extends ChangeNotifier {
  final SaveUserUseCase _saveUser;

  RegisterState _state = const RegisterState();

  RegisterState get state => _state;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  RegisterViewModel(this._saveUser);

  void onNameChanged(String name) {
    _state = _state.copyWith(name: name);
    notifyListeners();
  }

  void validateName(String name) {}

  void onBirthdateChanged(String birthdateText) {
    _state = _state.copyWith(birthdateText: birthdateText);
    notifyListeners();
  }

  void onHeightChanged(String heightText) {
    _state = _state.copyWith(heightText: heightText);
    notifyListeners();
  }

  void onWeightChanged(String weightText) {
    _state = _state.copyWith(weightText: weightText);
    notifyListeners();
  }

  void onSexChanged(BodySex sex) {
    _state = _state.copyWith(sex: sex);
    notifyListeners();
  }

  Future<void> save(UserModel user) async {
    try {
      _isSaving = true;
      notifyListeners();
      await _saveUser(user);
    } catch (e) {
      log(e.toString());
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

DateTime? parseBirthdate(String text) {
  final parts = text.split('/');

  if (parts.length != 3) {
    return null;
  }

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);

  if (day == null || month == null || year == null) {
    return null;
  }

  try {
    final date = DateTime(year, month, day);

    // DateTime corrige datas inválidas, então precisamos verificar.
    if (date.year != year ||
        date.month != month ||
        date.day != day) {
      return null;
    }

    return date;
  } catch (_) {
    return null;
  }
}