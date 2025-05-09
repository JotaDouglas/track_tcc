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
  Login? loginUser;

  @observable
  String? errorMessage;

  @observable
  String? idNewUser;

  //Criação de conta via email e senha
  Future createEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AuthResponse? create = await authRepository
          .createUserWithEmailAndPassword(email: email, password: password);
      if (create?.user != null) {
        idNewUser = create?.user!.id;
      }
      return true;
    } catch (e) {
      log("Erro ao criar usuário: $e");
      return false;
    }
  }

  // login com shared preferences
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      var usuario =
          await authRepository.loginWithEmail(email: email, password: password);
      if (usuario.user != null) {
        loginUser = Login(
          email: usuario.user!.email,
          uidUsuario: usuario.user!.id,
          id: usuario.user!.id,
        );
        saveUserData(loginUser!);
      }
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  // Salva os dados do usuário no SharedPreferences
  Future<void> saveUserData(Login login) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(login.toJson());
    await prefs.setString('user_data', jsonString);
  }

  // Recupera os dados do usuário salvo no SharedPreferences
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

  /// 🔹 Esqueci minha senha
  Future<bool> forgetKey({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email);
    return true;
  }

  /// 🔹 Faz logout e limpa os dados salvos
  Future<void> logout() async {
    await supabase.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data'); // Remove os dados do usuário
    loginUser = null; // Limpa o estado local
  }

  Future insertUsuario(
      {required String nome, required String sobrenome}) async {
    await supabase
        .from('usuarios')
        .insert({'nome': nome, 'sobrenome': sobrenome});
  }
}
