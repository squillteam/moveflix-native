import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:moveflix/core/domain/models/body_sex.dart';
import 'package:moveflix/core/domain/models/user.dart';
import 'package:moveflix/features/profile/domain/usecases/save_user_use_case.dart';

class RegisterState {
  final String name;
  final String birthdateText;
  final String heightText;
  final String weightText;
  final BodySex sex;
  final bool isSaved;

  const RegisterState({
    this.name = '',
    this.birthdateText = '',
    this.heightText = '',
    this.weightText = '',
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
      weightText: weightText ?? this.weightText,
      sex: sex ?? this.sex,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  UserModel? tryCreateUserModel() {
    if (weight == null || height == null || birthdate == null) {
      return null;
    }

    return UserModel(
        name: name,
        sex: sex,
        birthday: birthdate!,
        weight: weight!,
        height: height!,
    );
  }

  // Derived states
  bool get isNameValid => name.isNotEmpty && name.trim().split(" ").length >= 2;

  DateTime? get birthdate => parseBirthdate(birthdateText);
  bool get isBirthdateValid => birthdate != null;

  int? get height => int.tryParse(heightText.replaceAll(" cm", ""));
  bool get isHeightValid => height != null && height! > 100;

  double? get weight => double.tryParse(weightText.replaceAll(" kg", "").replaceAll(",", "."));
  bool get isWeightValid => weight != null && weight! > 40;
}

class RegisterViewModel extends ChangeNotifier {
  final SaveUserUseCase _saveUserUseCase;

  RegisterState _state = const RegisterState();
  RegisterState get state => _state;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  RegisterViewModel({
    required SaveUserUseCase saveUserUseCase,
  }) : _saveUserUseCase = saveUserUseCase;

  void onNameChanged(String name) {
    _state = _state.copyWith(name: name);
    notifyListeners();
  }

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

  Future<void> register() async {
    try {
      _isSaving = true;
      notifyListeners();

      final user = _state.tryCreateUserModel();
      if (user == null) {
        throw Exception("Failed to create user model");
      }

      await _saveUserUseCase(user);
      _state = _state.copyWith(isSaved: true);
    } catch (e) {
      log(e.toString());
      _state = _state.copyWith(isSaved: false);
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

  if (day == null || month == null || year == null || parts[2].length != 4) {
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