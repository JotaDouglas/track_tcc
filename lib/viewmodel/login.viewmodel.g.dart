// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LoginViewModel on LoginViewModelBase, Store {
  late final _$loginUserAtom =
      Atom(name: 'LoginViewModelBase.loginUser', context: context);

  @override
  Login? get loginUser {
    _$loginUserAtom.reportRead();
    return super.loginUser;
  }

  @override
  set loginUser(Login? value) {
    _$loginUserAtom.reportWrite(value, super.loginUser, () {
      super.loginUser = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: 'LoginViewModelBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$userCredentialAtom =
      Atom(name: 'LoginViewModelBase.userCredential', context: context);

  @override
  UserCredential? get userCredential {
    _$userCredentialAtom.reportRead();
    return super.userCredential;
  }

  @override
  set userCredential(UserCredential? value) {
    _$userCredentialAtom.reportWrite(value, super.userCredential, () {
      super.userCredential = value;
    });
  }

  @override
  String toString() {
    return '''
loginUser: ${loginUser},
errorMessage: ${errorMessage},
userCredential: ${userCredential}
    ''';
  }
}
