// import 'dart:convert';
import 'dart:convert';
import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/model/login.model.dart';
import 'package:track_tcc_app/repository/auth.repository.dart';

part 'login.viewmodel.g.dart';

class LoginViewModel = LoginViewModelBase with _$LoginViewModel;

abstract class LoginViewModelBase with Store {
  AuthRepository authRepository = AuthRepository();
  final supabase = Supabase.instance.client;

  @observable
  Login? loginUser; // Usuário autenticado
  @observable
  String? errorMessage;
  @observable

  /// 🔹 Faz login e salva os dados no SharedPreferences
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      var usuario = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (usuario.user != null) {
        loginUser = Login(
          email: usuario.user!.email,
          uidUsuario: usuario.user!.id,
          id: usuario.user!.id,
        );
        saveUserData(loginUser!);
      }
      errorMessage = null; // Limpa erro se o login for bem-sucedido
    } catch (e) {
      errorMessage = e.toString();
      // userCredential = null;
    }
  }

  // 🔹 Salva os dados do usuário no SharedPreferences
  Future<void> saveUserData(Login login) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(login.toJson());
    await prefs.setString('user_data', jsonString);
  }

  // /// 🔹 Recupera os dados do usuário salvo no SharedPreferences
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString('user_data');

    if (jsonString != null) {
      log("Usuário carregado do SharedPreferences: $jsonString");

      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      runInAction(() {
        loginUser = Login.fromJson(jsonMap);
      });
    } else {
      log("Nenhum usuário encontrado no SharedPreferences");
    }
  }

  /// 🔹 Cria um usuário e salva os dados
  Future createEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      log("Erro ao criar usuário: $e");
      return null;
    }
  }

  /// 🔹 Esqueci minha senha
  Future<bool> forgetKey({required String email}) async {
    // return await authRepository.forgetKey(email);
    return false;
  }

  /// 🔹 Faz logout e limpa os dados salvos
  Future<void> logout() async {
    // await authRepository.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data'); // Remove os dados do usuário
    loginUser = null; // Limpa o estado local
  }
}
