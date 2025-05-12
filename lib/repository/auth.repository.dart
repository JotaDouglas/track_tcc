import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  late SharedPreferences preferences;
  final supabase = Supabase.instance.client;

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
      return null;
    }
  }

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
}
