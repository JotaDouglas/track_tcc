import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';

class GroupRepositorySupabase {
  final SupabaseClient client;
  GroupRepositorySupabase(this.client);

  // Gerador de código: 6 chars alfanuméricos com entropia
  String _generateCode([int length = 6]) {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; // sem ambíguos
    final rnd = Random.secure();
    return List.generate(length, (_) => chars[rnd.nextInt(chars.length)])
        .join();
  }

  Future<String> _generateUniqueCode() async {
    for (var i = 0; i < 8; i++) {
      final candidate = _generateCode();
      final resp = await client
          .from('grupos')
          .select('id_grupo')
          .eq('codigo', candidate)
          .maybeSingle();
      if (resp == null || (resp is List && resp.isEmpty)) return candidate;
      // se existir, continua
    }
    // fallback com timestamp hash
    final bytes = utf8.encode(DateTime.now().toIso8601String());
    return sha1.convert(bytes).toString().substring(0, 6).toUpperCase();
  }

  Future<Group> createGroup(
      {required String nome,
      String? descricao,
      required String criadoPor,
      bool aberto = false}) async {
    final codigo = await _generateUniqueCode();
    final insert = {
      'nome': nome,
      'descricao': descricao,
      'codigo': codigo,
      'criado_por': criadoPor,
      'aberto': aberto,
    };
    final res =
        await client.from('grupos').insert(insert).select().maybeSingle();
    if (res == null) throw Exception('Erro ao criar grupo');
    final group = Group.fromMap(res);

    // adiciona o criador como admin no grupo_membros
    await client.from('grupo_membros').insert({
      'grupo_id': group.id,
      'user_id': criadoPor,
      'papel': 'admin',
      'adicionado_por': criadoPor,
    });

    return group;
  }

  Future<Group?> getGroupByCode(String codigo) async {
    final res =
        await client.from('grupos').select().eq('codigo', codigo).maybeSingle();
    if (res == null) return null;
    return Group.fromMap(res);
  }

  Future<void> addMember(
      {required String grupoId,
      required String userId,
      required String adicionadoPor,
      String papel = 'member'}) async {
    // evita duplicidade
    final exists = await client
        .from('grupo_membros')
        .select('id')
        .eq('grupo_id', grupoId)
        .eq('user_id', userId)
        .maybeSingle();
    if (exists != null) return;
    await client.from('grupo_membros').insert({
      'grupo_id': grupoId,
      'user_id': userId,
      'papel': papel,
      'adicionado_por': adicionadoPor,
    });
  }

  Future<void> removeMember(
      {required String grupoId, required String userId}) async {
    await client
        .from('grupo_membros')
        .delete()
        .eq('grupo_id', grupoId)
        .eq('user_id', userId);
  }

  Future<List<Group>> listGroupsForUser(String userId) async {
    // busca grupos onde user está em grupo_membros
    final res = await client
        .from('grupos')
        .select('*, grupo_membros!inner(user_id)')
        .eq('grupo_membros.user_id', userId);
    if (res == null) return [];
    return (res as List)
        .map((e) => Group.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GroupMember>> listMembers(String grupoId) async {
    final res = await client
        .from('grupo_membros')
        .select('*, usuarios:user_id (nome, sobrenome, message_id)')
        .eq('grupo_id', grupoId)
        .order('id', ascending: true);

    if (res == null) return [];

    return (res as List)
        .map((m) => GroupMember.fromMap(m as Map<String, dynamic>))
        .toList();
  }

  Future<void> promoteToAdmin(
      {required String grupoId, required String userId}) async {
    await client
        .from('grupo_membros')
        .update({'papel': 'admin'})
        .eq('grupo_id', grupoId)
        .eq('user_id', userId);
  }

  /// Retorna todos os message_ids (OneSignal player IDs) dos membros de um grupo
  /// Útil para enviar notificações em massa para todos os membros
  Future<List<String>> getGroupMemberMessageIds(String grupoId) async {
    final res = await client
        .from('grupo_membros')
        .select('usuarios:user_id (message_id)')
        .eq('grupo_id', grupoId);

    if (res.isEmpty) return [];

    final messageIds = <String>[];
    for (var item in res) {
      final usuarios = item['usuarios'];
      if (usuarios != null && usuarios['message_id'] != null) {
        messageIds.add(usuarios['message_id'] as String);
      }
    }

    return messageIds;
  }

  Stream<dynamic> watchGroup(String grupoId) {
    return client
        .from('grupo_membros:grupo_id=eq.$grupoId')
        .stream(primaryKey: ['id']);
  }
}
