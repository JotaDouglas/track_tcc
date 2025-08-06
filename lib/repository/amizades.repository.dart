import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class AmizadesRepository {
  final supabase = Supabase.instance.client;

  Future<void> enviarSolicitacaoAmizade(String meuId, String idAmigo) async {
    final response = await Supabase.instance.client.from('amizades').insert({
      'usuario_id': meuId,
      'amigo_id': idAmigo,
      'status': 'pendente',
    });

    if (response.error != null) {
      log('Erro ao enviar solicitação: ${response.error!.message}');
    } else {
      log('Solicitação enviada!');
    }
  }

  Future<List<Map<String, dynamic>>> getSolicitacoesPendentes(
      String meuUserId) async {
    try {
      final response = await Supabase.instance.client
          .from('amizades')
          .select(
              'id, usuario_id, usuarios!amizades_usuario_id_fkey(nome, sobrenome, email)')
          .eq('amigo_id', meuUserId)
          .eq('status', 'pendente');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Erro ao buscar solicitações: $e');
      return [];
    }
  }

  Future<void> aceitarAmizade(int amizadeId) async {
    final response = await Supabase.instance.client
        .from('amizades')
        .update({'status': 'aceito'}).eq('id', amizadeId);

    if (response.error != null) {
      log('Erro ao aceitar amizade: ${response.error!.message}');
    } else {
      log('Amizade aceita com sucesso!');
    }
  }

  Future<void> recusarAmizade(int amizadeId) async {
    final response = await Supabase.instance.client
        .from('amizades')
        .update({'status': 'recusado'}).eq('id', amizadeId);

    if (response.error != null) {
      log('Erro ao recusar amizade: ${response.error!.message}');
    } else {
      log('Solicitação recusada.');
    }
  }

  Future<List<Map<String, dynamic>>> getAmigos(String meuUserId) async {
    try {
      final data = await Supabase.instance.client
          .from('amizades')
          .select(
              'id, usuario_id, amigo_id, usuarios!amizades_usuario_id_fkey(nome, sobrenome), usuarios!amizades_amigo_id_fkey(nome, sobrenome)')
          .eq('status', 'aceito')
          .or('usuario_id.eq.$meuUserId,amigo_id.eq.$meuUserId');

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('Erro ao buscar amizades bilaterais: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> buscarAmigos(String termo) async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;

      var res = await supabase
          .from('usuarios')
          .select('id_usuario, nome, sobrenome, user_id')
          .or('nome.ilike.%$termo%,sobrenome.ilike.%$termo%')
          .neq('user_id', currentUserId!);

      return res;
    } catch (e) {
      return [];
    }
  }
}
