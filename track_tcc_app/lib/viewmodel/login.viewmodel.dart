import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:track_tcc_app/repository/auth.repository.dart';
part 'login.viewmodel.g.dart';

class LoginViewModel = LoginViewModelBase with _$LoginViewModel;

abstract class LoginViewModelBase with Store {
  AuthRepository authRepository = AuthRepository();

  Future loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future createEmailAndPassword({
    required String email,
    required String password,
  }) async {

    var res = await authRepository.authStateChanges;
    log(res.toString());
    await authRepository.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
