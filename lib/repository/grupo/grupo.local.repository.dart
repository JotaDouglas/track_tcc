import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:track_tcc_app/helper/database.helper.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';

class GrupoLocalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ========== Inicialização e setup ==========

  Future<void> _inicializarTabelas(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS grupos (
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        descricao TEXT,
        aberto INTEGER DEFAULT 0,
        codigo TEXT NOT NULL,
        criado_por TEXT NOT NULL,
        criado_em TEXT NOT NULL,
        atualizado_em TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS grupos_membros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        grupo_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        papel TEXT NOT NULL DEFAULT 'member',
        adicionado_por TEXT NOT NULL,
        adicionado_em TEXT NOT NULL,
        nome TEXT,
        sobrenome TEXT,
        FOREIGN KEY (grupo_id) REFERENCES grupos(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_grupos_membros_grupo_id
      ON grupos_membros(grupo_id);
    ''');
  }

  Future<void> limparTabelasGrupos() async {
    final db = await _dbHelper.database;
    await _inicializarTabelas(db);

    await db.delete('grupos_membros');
    await db.delete('grupos');
    log('🧹 Tabelas de grupos e membros limpas');
  }

  // ========== Operações com grupos ==========

  Future<void> salvarGrupos(List<Group> grupos) async {
    final db = await _dbHelper.database;
    await _inicializarTabelas(db);

    final batch = db.batch();

    for (var grupo in grupos) {
      batch.insert(
        'grupos',
        _converterGrupoParaMapa(grupo),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('💾 ${grupos.length} grupos salvos no SQLite');
  }

  Future<List<Group>> carregarGrupos() async {
    final db = await _dbHelper.database;
    await _inicializarTabelas(db);

    final dados = await db.query('grupos', orderBy: 'criado_em DESC');
    if (dados.isEmpty) return [];

    List<Group> grupos = [];
    for (var linha in dados) {
      final grupo = _converterMapaParaGrupo(linha);
      grupo.membros = await carregarMembrosGrupo(grupo.id);
      grupos.add(grupo);
    }

    log('📖 ${grupos.length} grupos carregados do SQLite');
    return grupos;
  }

  Future<void> atualizarGrupo(Group grupo) async {
    final db = await _dbHelper.database;
    await _inicializarTabelas(db);

    await db.update(
      'grupos',
      {
        'nome': grupo.nome,
        'descricao': grupo.descricao,
        'aberto': grupo.aberto ? 1 : 0,
        'codigo': grupo.codigo,
        'atualizado_em': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [grupo.id],
    );

    if (grupo.membros != null) {
      await salvarMembrosGrupo(grupo.id, grupo.membros!);
    }

    log('🔄 Grupo ${grupo.id} atualizado no SQLite');
  }

  Future<void> removerGrupo(String grupoId) async {
    final db = await _dbHelper.database;
    await _inicializarTabelas(db);

    await db.delete('grupos_membros', where: 'grupo_id = ?', whereArgs: [grupoId]);
    await db.delete('grupos', where: 'id = ?', whereArgs: [grupoId]);

    log('🗑️ Grupo $grupoId removido do SQLite');
  }

  // ========== Operações com membros ==========

  Future<void> salvarMembrosGrupo(String grupoId, List<GroupMember> membros) async {
    final db = await _dbHelper.database;
    await _inicializarTabelas(db);

    await db.delete('grupos_membros', where: 'grupo_id = ?', whereArgs: [grupoId]);

    if (membros.isEmpty) return;

    final batch = db.batch();
    for (var membro in membros) {
      batch.insert(
        'grupos_membros',
        _converterMembroParaMapa(grupoId, membro),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('💾 ${membros.length} membros do grupo $grupoId salvos no SQLite');
  }

  Future<List<GroupMember>> carregarMembrosGrupo(String grupoId) async {
    final db = await _dbHelper.database;
    await _inicializarTabelas(db);

    final dados = await db.query(
      'grupos_membros',
      where: 'grupo_id = ?',
      whereArgs: [grupoId],
      orderBy: 'adicionado_em ASC',
    );

    if (dados.isEmpty) return [];

    return dados.map((linha) => _converterMapaParaMembro(linha)).toList();
  }

  // ========== Métodos auxiliares ==========

  Map<String, dynamic> _converterGrupoParaMapa(Group grupo) {
    return {
      'id': grupo.id,
      'nome': grupo.nome,
      'descricao': grupo.descricao,
      'aberto': grupo.aberto ? 1 : 0,
      'codigo': grupo.codigo,
      'criado_por': grupo.criadoPor,
      'criado_em': grupo.criadoEm.toIso8601String(),
      'atualizado_em': grupo.atualizadoEm.toIso8601String(),
    };
  }

  Group _converterMapaParaGrupo(Map<String, dynamic> linha) {
    return Group(
      id: linha['id'] as String,
      nome: linha['nome'] as String,
      descricao: linha['descricao'] as String?,
      codigo: linha['codigo'] as String,
      aberto: (linha['aberto'] as int) == 1,
      criadoPor: linha['criado_por'] as String,
      criadoEm: DateTime.parse(linha['criado_em'] as String),
      atualizadoEm: DateTime.parse(linha['atualizado_em'] as String),
    );
  }

  Map<String, dynamic> _converterMembroParaMapa(String grupoId, GroupMember membro) {
    return {
      'grupo_id': grupoId,
      'user_id': membro.userId,
      'papel': membro.papel,
      'adicionado_por': membro.adicionadoPor,
      'adicionado_em': membro.adicionadoEm.toIso8601String(),
      'nome': membro.nome,
      'sobrenome': membro.sobrenome,
    };
  }

  GroupMember _converterMapaParaMembro(Map<String, dynamic> linha) {
    return GroupMember(
      id: linha['id'] as int,
      grupoId: linha['grupo_id'] as String,
      userId: linha['user_id'] as String,
      papel: linha['papel'] as String,
      adicionadoPor: linha['adicionado_por'] as String,
      adicionadoEm: DateTime.parse(linha['adicionado_em'] as String),
      nome: linha['nome'] as String?,
      sobrenome: linha['sobrenome'] as String?,
    );
  }
}
