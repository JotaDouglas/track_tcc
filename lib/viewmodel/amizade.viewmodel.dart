import 'dart:developer';

import 'package:mobx/mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/repository/amizades.repository.dart';

part 'amizade.viewmodel.g.dart';

class AmizadeViewModel = AmizadeViewModelBase with _$AmizadeViewModel;

abstract class AmizadeViewModelBase with Store {
  final AmizadesRepository _amizadesRepository = AmizadesRepository();

  final supabase = Supabase.instance.client;

  @observable
  List<Map<String, dynamic>> friends = [];

  @action
  changeFriends(List<Map<String, dynamic>> f) async => friends = List.from(f);

  @action
  readMyFriends({bool onlyFriends = false, bool solicitations = false}) async {
    final currentUserId = supabase.auth.currentUser?.id;
    var dados = await _amizadesRepository.getAllAmigos(currentUserId!);

    if (onlyFriends) {
      dados.removeWhere((element) => element['status'] == 'pendente');
    } else if (solicitations) {
      dados.removeWhere((element) => element['status'] == 'aceito');
    }

    await changeFriends(dados);
  }

  Future enviarSolicitacaoAmizade(String meuId, String idAmigo) async {
    try {
      bool sendSolicitacao =
          await _amizadesRepository.enviarSolicitacaoAmizade(meuId, idAmigo);

      return sendSolicitacao;
    } catch (e) {
      log("erro ao enviar a solicitação: $e");
      return false;
    }
  }

  Future cancelarSolicitacaoAmizade(String idAmigo) async {
    try {
      var amigo = friends.firstWhere(
        (e) => e['usuario_id'] == idAmigo || e['amigo_id'] == idAmigo,
        orElse: () => {},
      );

      if (amigo.isEmpty) return false;

      bool delete = await _amizadesRepository.desfazerAmizade(
          amigo['id'] is int ? amigo['id'] : int.tryParse(amigo['id']) ?? -1);

      if (delete) {
        friends.removeWhere(
            (e) => e['usuario_id'] == idAmigo || e['amigo_id'] == idAmigo);
      }

      return delete;
    } catch (e) {
      log("erro ao enviar a solicitação: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> buscarAmigos(String termo) async {
    final currentUserId = supabase.auth.currentUser?.id;
    List<Map<String, dynamic>> response = [];

    if (termo.isEmpty || currentUserId == null) {
      return response;
    }

    try {
      response = await _amizadesRepository.buscarAmigos(termo);
      final data = List<Map<String, dynamic>>.from(response);
      return data;
    } catch (e) {
      return [];
    }
  }
}
