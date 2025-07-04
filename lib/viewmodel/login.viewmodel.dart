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

  @observable
  String? emailUser;

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
        emailUser = create?.user?.email;
        return true;
      } else {
        return false;
      }
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
        var dadosUsuario = await loadUsuario(usuario.user!.id);

        loginUser = Login(
          email: usuario.user!.email,
          uidUsuario: usuario.user!.id,
          id: dadosUsuario != null ? dadosUsuario['id_usuario'] : 000,
          username: dadosUsuario != null ? dadosUsuario['nome'] : "usuario",
          sobrenome: dadosUsuario != null ? dadosUsuario['sobrenome'] : "",
          bio: dadosUsuario != null ? dadosUsuario['biografia'] : "",
        );
        saveUserData(loginUser!);
      }
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> reloadUser() async {
    var dadosUsuario = await loadUsuario(loginUser!.uidUsuario!);
    var usuario = loginUser!;

    loginUser = Login(
      email: usuario.email,
      uidUsuario: usuario.uidUsuario,
      id: dadosUsuario['id_usuario'],
      username: dadosUsuario['nome'] ?? "usuario",
      sobrenome: dadosUsuario['sobrenome'] ?? "",
      bio: dadosUsuario['biografia'] ?? "",
    );
    saveUserData(loginUser!);
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
      // log("Usuário carregado do SharedPreferences: $jsonString");

      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      runInAction(() {
        loginUser = Login.fromJson(jsonMap);
      });
    } else {
      log("Nenhum usuário encontrado no SharedPreferences");
    }
  }

  //Esqueci minha senha
  Future<bool> forgetKey({required String email}) async {
    await authRepository.forgetKey(email);
    return true;
  }

  //Faz logout e limpa os dados salvos
  Future<void> logout() async {
    await authRepository.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data'); // Remove os dados do usuário
    loginUser = null; // Limpa o estado local
  }

  Future insertUsuario({
    required String nome,
    required String sobrenome,
    String? uuid,
    String? biografia,
  }) async {
    if(uuid != null){
      emailUser = loginUser!.email;
    }
    var res = await supabase.from('usuarios').insert(
      {
        'nome': nome,
        'sobrenome': sobrenome,
        "email": emailUser,
        "user_id": uuid ?? idNewUser,
        "tipo_usuario": "responsavel",
        'biografia': biografia,
      },
    );

    if(uuid != null){
      await reloadUser();
    }

    return true;
  }

  Future<bool> updateUsuario({
    required int userId,
    required String nome,
    required String sobrenome,
    required String biografia,
  }) async {
    try {
      log(idNewUser.toString());
      final data = {
        'nome': nome,
        'sobrenome': sobrenome,
        'biografia': biografia,
      };

      final response = await supabase
          .from('usuarios')
          .update(data)
          .eq('id_usuario', userId)
          .select(); // importante para ver o resultado da atualização

      if (response.isEmpty) {
        log('Nenhum registro foi atualizado.');
        return false; // não atualizou nada
      }

      var dados = response.first;

      loginUser = Login(
        email: dados['email'],
        uidUsuario: dados['user_id'],
        id: dados['id_usuario'],
        username: dados['nome'] ?? "usuario",
        sobrenome: dados['sobrenome'] ?? "",
        bio: dados['biografia'] ?? "",
      );

      saveUserData(loginUser!);

      loadUserFromPrefs();

      // log('Atualização bem-sucedida: $response');
      return true;
    } catch (e) {
      log('Erro ao atualizar: $e');
      return false;
    }
  }

  Future loadUsuario(String id) async {
    try {
      var res = await authRepository.loadUsuario(id);
      return res;
    } catch (e) {
      return null;
    }
  }
}
