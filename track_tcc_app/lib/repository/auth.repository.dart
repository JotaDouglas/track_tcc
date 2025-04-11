import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late SharedPreferences preferences;
  User? get currentUser => _firebaseAuth.currentUser;


  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential? res = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if(res.user?.email != null){
        preferences = await SharedPreferences.getInstance(); 
        preferences.setString("email", res.user!.email!);       
      }
      return res;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'invalid-credential':
        return 'Usuário não encontrado.';
      default:
        return 'Ocorreu um erro inesperado.';
    }
  }

  Future createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      var res = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verifica se a criação foi bem-sucedida e obtém as informações do usuário
      if (res.user != null) {
        // A criação do usuário foi bem-sucedida
        log("Usuário criado com sucesso: ${res.user!.email}");
        // Aqui você pode fazer outras operações, como navegar para outra tela
        return res.user; // Retorna o usuário criado
      } else {
        // Se o usuário não foi criado corretamente
        log("Erro: não foi possível criar o usuário.");
        return null;
      }
      // return res;
    } on FirebaseException catch (e) {
      // Imprime o erro para entender o que aconteceu
      log("Erro ao criar usuário: ${e.message}");
      log("Código do erro: ${e.code}");
      log("Detalhes do erro: ${e.stackTrace}");
      // Opcionalmente, você pode lançar o erro novamente ou retornar um valor específico
      return null; // Ou qualquer outro valor para indicar falha
    }
  }

  Future forgetKey(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      log("E-mail de redefinição de senha enviado para: $email");
      return true;
    } catch (e) {
      log("Erro ao enviar e-mail de redefinição de senha: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
