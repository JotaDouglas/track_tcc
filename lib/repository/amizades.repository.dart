import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

class AmizadesRepository {
  // Instância do cliente do Supabase
  final supabase = Supabase.instance.client;

  // Envia uma solicitação de amizade criando um registro com status "pendente"
  Future enviarSolicitacaoAmizade(String meuId, String idAmigo) async {
    try {
      await supabase
          .from('amizades')
          .insert({
            'usuario_id': meuId,
            'amigo_id': idAmigo,
            'status': 'pendente',
          })
          .select()
          .single();

      return true;
    } catch (e) {
      log("erro $e");
      return false;
    }
  }

  // Obtém todas as solicitações pendentes que foram enviadas para o usuário atual
  Future<List<Map<String, dynamic>>> getSolicitacoesPendentes(
      String meuUserId) async {
    try {
      // Select com relacionamento: usuários relacionados pelo FKey 'amizades_usuario_id_fkey'
      // Quem está recebendo a solicitação é o usuário logado
      // Só solicitações ainda não aceitas ou recusadas
      final response = await supabase
          .from('amizades')
          .select(
              'id, usuario_id, usuarios!amizades_usuario_id_fkey(nome, sobrenome, email)')
          .eq('amigo_id', meuUserId)
          .eq('status', 'pendente');

      // Supabase retorna List<dynamic>, aqui convertemos para o tipo esperado
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Erro ao buscar solicitações: $e');
      return [];
    }
  }

  // Aceita uma solicitação de amizade mudando seu status para "aceito"
  Future<bool> aceitarAmizade(int amizadeId) async {
    try {
      await supabase
          .from('amizades')
          .update({'status': 'aceito'}).eq('id', amizadeId);

      return true;
    } catch (e) {
      log('Erro ao aceitar amizade: $e');
      return false;
    }
  }

  // Recusa uma solicitação de amizade mudando o status para "recusado"
  Future<void> recusarAmizade(int amizadeId) async {
    final response = await supabase
        .from('amizades')
        .update({'status': 'recusado'}).eq('id', amizadeId);

    if (response.error != null) {
      log('Erro ao recusar amizade: ${response.error!.message}');
    } else {
      log('Solicitação recusada.');
    }
  }

  // Exclui o vínculo de amizade
  Future<bool> desfazerAmizade(int amizadeId) async {
    try {
      await supabase.from('amizades').delete().eq('id', amizadeId);

      return true;
    } catch (e) {
      log("Erro ao desfazer amizade: $e");
      return false;
    }
  }

  // Busca amigos já aceitos e relacionados ao usuário
  Future<List<Map<String, dynamic>>> getAmigos(String meuUserId) async {
    try {
      final data = await supabase
          .from('amizades')
          .select('id, usuario_id, amigo_id, '
              'usuarios!amizades_usuario_id_fkey(nome, sobrenome), '
              'usuarios!amizades_amigo_id_fkey(nome, sobrenome)')
          .eq('status', 'aceito')
          .or('usuario_id.eq.$meuUserId,amigo_id.eq.$meuUserId');

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('Erro ao buscar amizades bilaterais: $e');
      return [];
    }
  }

  // Igual ao anterior, mas retorna mais informações de ambos usuários
  Future<List<Map<String, dynamic>>> getAllAmigos(String meuUserId) async {
    try {
      final data = await supabase
          .from('amizades')
          .select('id, usuario_id, amigo_id, '
              'remetente:usuarios!amizades_usuario_id_fkey(nome, sobrenome, message_id, email), '
              'destinatario:usuarios!amizades_amigo_id_fkey(nome, sobrenome, message_id, email), '
              'status')
          .or('usuario_id.eq.$meuUserId,amigo_id.eq.$meuUserId');

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      log('Erro ao buscar amizades bilaterais: $e');
      return [];
    }
  }

  // Busca usuários pelo nome ou sobrenome (para enviar nova solicitação)
  Future<List<Map<String, dynamic>>> buscarAmigos(String termo) async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;

      final res = await supabase
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
