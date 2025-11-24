import 'dart:convert';
import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/model/login.model.dart';
import 'package:track_tcc_app/repository/auth.repository.dart';

part 'login.viewmodel.g.dart';

class LoginViewModel = LoginViewModelBase with _$LoginViewModel;

abstract class LoginViewModelBase with Store {
  final AuthRepository _authRepository = AuthRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

  @observable
  Login? loginUser;

  @observable
  String? errorMessage;

  @observable
  String? idNewUser;

  @observable
  String? emailUser;

  // Cria uma nova conta de usuário com email e senha
  // Retorna true se a conta foi criada com sucesso
  Future<bool> createEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (response?.user != null) {
        idNewUser = response!.user!.id;
        emailUser = response.user?.email;
        return true;
      }

      return false;
    } catch (e) {
      log("Erro ao criar usuário: $e");
      return false;
    }
  }

  // Realiza login com email e senha
  // Carrega dados do usuário e salva localmente
  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _authRepository.loginWithEmail(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        errorMessage = "Falha no login";
        return;
      }

      await _loadAndSaveUserData(authResponse.user!);
      await _updateUserMessageId();

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
      log("Erro ao fazer login: $e");
    }
  }

  // Carrega dados do usuário do banco e salva no estado local
  Future<void> _loadAndSaveUserData(User user) async {
    final dadosUsuario = await _loadUsuarioData(user.id);

    loginUser = Login(
      email: user.email,
      uidUsuario: user.id,
      id: dadosUsuario?['id_usuario'] ?? 0,
      username: dadosUsuario?['nome'] ?? "usuario",
      sobrenome: dadosUsuario?['sobrenome'] ?? "",
      bio: dadosUsuario?['biografia'] ?? "",
    );

    await _saveUserToPreferences(loginUser!);
  }

  // Atualiza o ID de mensagem do usuário (OneSignal)
  Future<void> _updateUserMessageId() async {
    await Future.delayed(const Duration(seconds: 1));

    final userId = _supabase.auth.currentUser?.id;
    final playerId = OneSignal.User.pushSubscription.id;

    if (playerId != null && userId != null) {
      await _supabase.from('usuarios').update({
        'message_id': playerId,
      }).eq('user_id', userId);
    }
  }

  // Recarrega os dados do usuário atual do banco
  Future<void> reloadUser() async {
    if (loginUser == null) return;

    final dadosUsuario = await _loadUsuarioData(loginUser!.uidUsuario!);
    if (dadosUsuario == null) return;

    final usuario = loginUser!;

    loginUser = Login(
      email: usuario.email,
      uidUsuario: usuario.uidUsuario,
      id: dadosUsuario['id_usuario'],
      username: dadosUsuario['nome'] ?? "usuario",
      sobrenome: dadosUsuario['sobrenome'] ?? "",
      bio: dadosUsuario['biografia'] ?? "",
    );

    await _saveUserToPreferences(loginUser!);
  }

  // Realiza logout e limpa dados salvos
  Future<void> logout() async {
    await _authRepository.signOut();
    await _clearUserFromPreferences();
    loginUser = null;
  }

  // Salva os dados do usuário no SharedPreferences
  Future<void> _saveUserToPreferences(Login login) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(login.toJson());
    await prefs.setString('user_data', jsonString);
  }

  // Recupera os dados do usuário do SharedPreferences
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user_data');

    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      runInAction(() {
        loginUser = Login.fromJson(jsonMap);
      });
    } else {
      log("Nenhum usuário encontrado no SharedPreferences");
    }
  }

  // Remove os dados do usuário do SharedPreferences
  Future<void> _clearUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  // Envia email de recuperação de senha
  Future<bool> forgetKey({required String email}) async {
    try {
      await _authRepository.forgetKey(email);
      return true;
    } catch (e) {
      log("Erro ao enviar email de recuperação: $e");
      return false;
    }
  }

  // Insere um novo usuário no banco de dados
  Future<bool> insertUsuario({
    required String nome,
    required String sobrenome,
    String? uuid,
    String? biografia,
    bool termo = false,
  }) async {
    try {
      if (uuid != null) {
        emailUser = loginUser!.email;
      }

      await _supabase.from('usuarios').insert({
        'nome': nome,
        'sobrenome': sobrenome,
        "email": emailUser,
        "user_id": uuid ?? idNewUser,
        "tipo_usuario": "responsavel",
        'biografia': biografia,
        'termo': termo,
      });

      if (uuid != null) {
        await reloadUser();
      }

      return true;
    } catch (e) {
      log("Erro ao inserir usuário: $e");
      return false;
    }
  }

  // Atualiza os dados do usuário no banco
  Future<bool> updateUsuario({
    required int userId,
    required String nome,
    required String sobrenome,
    required String biografia,
  }) async {
    try {
      final data = {
        'nome': nome,
        'sobrenome': sobrenome,
        'biografia': biografia,
      };

      final response = await _supabase
          .from('usuarios')
          .update(data)
          .eq('id_usuario', userId)
          .select();

      if (response.isEmpty) {
        log('Nenhum registro foi atualizado.');
        return false;
      }

      _updateLoginUserFromResponse(response.first);
      await _saveUserToPreferences(loginUser!);
      await loadUserFromPrefs();

      return true;
    } catch (e) {
      log('Erro ao atualizar: $e');
      return false;
    }
  }

  // Atualiza o objeto loginUser com os dados da resposta do banco
  void _updateLoginUserFromResponse(Map<String, dynamic> dados) {
    loginUser = Login(
      email: dados['email'],
      uidUsuario: dados['user_id'],
      id: dados['id_usuario'],
      username: dados['nome'] ?? "usuario",
      sobrenome: dados['sobrenome'] ?? "",
      bio: dados['biografia'] ?? "",
    );
  }

  // Carrega os dados do usuário do banco pelo ID
  Future<Map<String, dynamic>?> _loadUsuarioData(String id) async {
    try {
      return await _authRepository.loadUsuario(id);
    } catch (e) {
      log("Erro ao carregar dados do usuário: $e");
      return null;
    }
  }

  // Exclui a conta do usuário permanentemente
  Future<bool> deleteUsuario() async {
    try {
      if (loginUser?.uidUsuario == null) {
        log("Usuário não está logado");
        return false;
      }

      final success = await _authRepository.deleteAccount(loginUser!.uidUsuario!);

      if (success) {
        // Limpa os dados locais após exclusão bem-sucedida
        await _clearUserFromPreferences();
        loginUser = null;
        return true;
      }

      return false;
    } catch (e) {
      log("Erro ao excluir conta do usuário: $e");
      return false;
    }
  }
}
