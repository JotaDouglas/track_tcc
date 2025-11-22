import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/repository/amizades.repository.dart';

part 'amizade.viewmodel.g.dart';

class AmizadeViewModel = AmizadeViewModelBase with _$AmizadeViewModel;

abstract class AmizadeViewModelBase with Store {
  final AmizadesRepository _amizadesRepository = AmizadesRepository();
  final SupabaseClient _supabase = Supabase.instance.client;

  @observable
  List<Map<String, dynamic>> friends = [];

  @observable
  List<Map<String, dynamic>> requests = [];

  @action
  void changeFriends(List<Map<String, dynamic>> newFriends) {
    friends = List.from(newFriends);
  }

  @action
  void changeRequests(List<Map<String, dynamic>> newRequests) {
    requests = List.from(newRequests);
  }

  /// Carrega todas as amizades do usuário atual
  /// Separa amigos aceitos e solicitações pendentes
  @action
  Future<void> readMyFriends({
    bool onlyFriends = false,
    bool solicitations = false,
  }) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    if (currentUserId == null) {
      log("Erro: Usuário não autenticado");
      return;
    }

    try {
      final dados = await _amizadesRepository.getAllAmigos(currentUserId);

      // Filtra amizades aceitas
      final friendsList = dados
          .where((e) => e['status'] == 'aceito')
          .cast<Map<String, dynamic>>()
          .toList();

      changeFriends(friendsList);

      // Filtra solicitações pendentes
      final requestsList = dados
          .where((e) => e['status'] == 'pendente')
          .cast<Map<String, dynamic>>()
          .toList();

      changeRequests(requestsList);
    } catch (e) {
      log("Erro ao carregar amizades: $e");
    }
  }

  /// Envia uma solicitação de amizade para outro usuário
  /// Retorna true se enviada com sucesso
  Future<bool> enviarSolicitacaoAmizade(String meuId, String idAmigo) async {
    try {
      final sucesso = await _amizadesRepository.enviarSolicitacaoAmizade(
        meuId,
        idAmigo,
      );

      return sucesso;
    } catch (e) {
      log("Erro ao enviar solicitação de amizade: $e");
      return false;
    }
  }

  /// Aceita uma solicitação de amizade
  /// Retorna true se aceita com sucesso
  Future<bool> aceitarAmizade(int idSolicitacao) async {
    try {
      final sucesso = await _amizadesRepository.aceitarAmizade(idSolicitacao);
      return sucesso;
    } catch (e) {
      log("Erro ao aceitar solicitação de amizade: $e");
      return false;
    }
  }

  /// Cancela uma amizade ou solicitação pendente
  /// Retorna true se cancelada com sucesso
  Future<bool> cancelarSolicitacaoAmizade(int idAmigo) async {
    try {
      final sucesso = await _amizadesRepository.desfazerAmizade(idAmigo);

      if (sucesso) {
        _removeFriendFromList(idAmigo);
        await readMyFriends();
      }

      return sucesso;
    } catch (e) {
      log("Erro ao cancelar amizade: $e");
      return false;
    }
  }

  /// Busca usuários por termo de pesquisa
  /// Retorna lista de usuários encontrados
  Future<List<Map<String, dynamic>>> buscarAmigos(String termo) async {
    final currentUserId = _supabase.auth.currentUser?.id;

    if (termo.isEmpty || currentUserId == null) {
      return [];
    }

    try {
      final response = await _amizadesRepository.buscarAmigos(termo);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log("Erro ao buscar amigos: $e");
      return [];
    }
  }

  /// Remove um amigo da lista local
  void _removeFriendFromList(int idAmigo) {
    friends.removeWhere(
      (e) => e['usuario_id'] == idAmigo || e['amigo_id'] == idAmigo,
    );
  }
}
