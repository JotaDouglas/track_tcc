import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
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

  Future<User?> createEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Criar o usuário
      User? userCredential =
          await authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? newUser = userCredential; // Obtém o usuário corretamente

      // Exibir informações do usuário no log
      log("Usuário criado: ${newUser?.uid}");
      return newUser;
    } catch (e) {
      log("Erro ao criar usuário: $e");
      return null;
    }
  }

  Future forgetKey({required String email})async{
    bool res = false;
    res = await authRepository.forgetKey(email);
    return res;
  }
}
