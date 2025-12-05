import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  late SharedPreferences preferences;
  final supabase = Supabase.instance.client;

  //Função de criação de conta, ela aguarda receber um email e senha(password)
  Future createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AuthResponse? account = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return account;
    } catch (e) {
      return e;
    }
  }

  //Função de login de usuario, ela aguarda receber um email e senha(password)
  Future loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      var usuario = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return usuario;
    } catch (e) {
      return null;
    }
  }

  Future forgetKey(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      log("E-mail de redefinição de senha enviado para: $email");
      return true;
    } catch (e) {
      log("Erro ao enviar e-mail de redefinição de senha: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future loadUsuario(String id) async {
    try {

      final data = await supabase
          .from('usuarios')
          .select()
          .eq('user_id', id);

      return data.first;

    } catch (e) {
      return null;
    }
  }

  // Exclui o usuário da tabela usuarios e faz sign out
  Future<bool> deleteAccount(String userId) async {
    try {
      // Deleta os dados do usuário da tabela usuarios
      await supabase.from('usuarios').delete().eq('user_id', userId);

      // Faz sign out da conta
      await supabase.auth.signOut();

      log("Conta do usuário excluída com sucesso");
      return true;
    } catch (e) {
      log("Erro ao excluir conta: $e");
      return false;
    }
  }
}
