import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';

class GroupRepositorySupabase {
  static const _chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const _tamanhoCodigoGrupo = 6;
  static const _tentativasGeracao = 8;

  final SupabaseClient client;

  GroupRepositorySupabase(this.client);

  // ========== Criação e busca de grupos ==========

  Future<Group> createGroup({
    required String nome,
    String? descricao,
    required String criadoPor,
    bool aberto = false,
  }) async {
    final codigo = await _gerarCodigoUnico();

    final dados = {
      'nome': nome,
      'descricao': descricao,
      'codigo': codigo,
      'criado_por': criadoPor,
      'aberto': aberto,
    };

    final resultado = await client
        .from('grupos')
        .insert(dados)
        .select()
        .maybeSingle();

    if (resultado == null) throw Exception('Erro ao criar grupo');

    final grupo = Group.fromMap(resultado);

    await client.from('grupo_membros').insert({
      'grupo_id': grupo.id,
      'user_id': criadoPor,
      'papel': 'admin',
      'adicionado_por': criadoPor,
    });

    return grupo;
  }

  Future<Group?> getGroupByCode(String codigo) async {
    final resultado = await client
        .from('grupos')
        .select()
        .eq('codigo', codigo)
        .maybeSingle();

    if (resultado == null) return null;
    return Group.fromMap(resultado);
  }

  Future<List<Group>> listGroupsForUser(String userId) async {
    final resultado = await client
        .from('grupos')
        .select('*, grupo_membros!inner(user_id)')
        .eq('grupo_membros.user_id', userId);

    return (resultado as List)
        .map((item) => Group.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // ========== Gestão de membros ==========

  Future<void> addMember({
    required String grupoId,
    required String userId,
    required String adicionadoPor,
    String papel = 'member',
  }) async {
    final jaExiste = await client
        .from('grupo_membros')
        .select('id')
        .eq('grupo_id', grupoId)
        .eq('user_id', userId)
        .maybeSingle();

    if (jaExiste != null) return;

    await client.from('grupo_membros').insert({
      'grupo_id': grupoId,
      'user_id': userId,
      'papel': papel,
      'adicionado_por': adicionadoPor,
    });
  }

  Future<void> removeMember({
    required String grupoId,
    required String userId,
  }) async {
    await client
        .from('grupo_membros')
        .delete()
        .eq('grupo_id', grupoId)
        .eq('user_id', userId);
  }

  Future<List<GroupMember>> listMembers(String grupoId) async {
    final resultado = await client
        .from('grupo_membros')
        .select('*, usuarios:user_id (nome, sobrenome, message_id)')
        .eq('grupo_id', grupoId)
        .order('id', ascending: true);

    return (resultado as List)
        .map((item) => GroupMember.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> promoteToAdmin({
    required String grupoId,
    required String userId,
  }) async {
    await client
        .from('grupo_membros')
        .update({'papel': 'admin'})
        .eq('grupo_id', grupoId)
        .eq('user_id', userId);
  }

  // ========== Notificações ==========

  Future<List<String>> getGroupMemberMessageIds(String grupoId) async {
    final resultado = await client
        .from('grupo_membros')
        .select('usuarios:user_id (message_id)')
        .eq('grupo_id', grupoId);

    if (resultado.isEmpty) return [];

    List<String> ids = [];
    for (var item in resultado) {
      final usuario = item['usuarios'];
      if (usuario != null && usuario['message_id'] != null) {
        ids.add(usuario['message_id'] as String);
      }
    }

    return ids;
  }

  // ========== Observadores ==========

  Stream<dynamic> watchGroup(String grupoId) {
    return client
        .from('grupo_membros:grupo_id=eq.$grupoId')
        .stream(primaryKey: ['id']);
  }

  // ========== Geração de códigos ==========

  String _gerarCodigo([int tamanho = _tamanhoCodigoGrupo]) {
    final random = Random.secure();
    return List.generate(
      tamanho,
      (_) => _chars[random.nextInt(_chars.length)],
    ).join();
  }

  Future<String> _gerarCodigoUnico() async {
    for (var tentativa = 0; tentativa < _tentativasGeracao; tentativa++) {
      final codigo = _gerarCodigo();

      final resultado = await client
          .from('grupos')
          .select('id_grupo')
          .eq('codigo', codigo)
          .maybeSingle();

      if (resultado == null || (resultado is List && resultado.isEmpty)) {
        return codigo;
      }
    }

    final timestamp = DateTime.now().toIso8601String();
    final hash = sha1.convert(utf8.encode(timestamp));
    return hash.toString().substring(0, _tamanhoCodigoGrupo).toUpperCase();
  }
}
