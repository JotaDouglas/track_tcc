import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:track_tcc_app/helper/database.helper.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
import 'package:track_tcc_app/model/grupo/membros.model.dart';

class GrupoLocalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Garante que as tabelas de grupos e membros existem
  Future<void> _ensureGrupoTables(Database db) async {
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

    // Tabela de membros dos grupos
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

    // Índice para otimizar consultas por grupo_id
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_grupos_membros_grupo_id
      ON grupos_membros(grupo_id);
    ''');
  }

  // Limpa todas as tabelas de grupos e membros
  Future<void> limparTabelasGrupos() async {
    final db = await _dbHelper.database;
    await _ensureGrupoTables(db);

    await db.delete('grupos_membros');
    await db.delete('grupos');
    log('🧹 Tabelas de grupos e membros limpas');
  }

  // Salva uma lista de grupos no SQLite
  Future<void> salvarGrupos(List<Group> grupos) async {
    final db = await _dbHelper.database;
    await _ensureGrupoTables(db);

    final batch = db.batch();

    for (final grupo in grupos) {
      batch.insert(
        'grupos',
        {
          'id': grupo.id,
          'nome': grupo.nome,
          'descricao': grupo.descricao,
          'aberto': grupo.aberto ? 1 : 0,
          'codigo': grupo.codigo,
          'criado_por': grupo.criadoPor,
          'criado_em': grupo.criadoEm.toIso8601String(),
          'atualizado_em': grupo.atualizadoEm.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('💾 ${grupos.length} grupos salvos no SQLite');
  }

  // Salva os membros de um grupo específico
  Future<void> salvarMembrosGrupo(
      String grupoId, List<GroupMember> membros) async {
    final db = await _dbHelper.database;
    await _ensureGrupoTables(db);

    // Remove membros antigos deste grupo
    await db
        .delete('grupos_membros', where: 'grupo_id = ?', whereArgs: [grupoId]);

    if (membros.isEmpty) return;

    final batch = db.batch();

    for (final membro in membros) {
      batch.insert(
        'grupos_membros',
        {
          'grupo_id': grupoId,
          'user_id': membro.userId,
          'papel': membro.papel,
          'adicionado_por': membro.adicionadoPor,
          'adicionado_em': membro.adicionadoEm.toIso8601String(),
          'nome': membro.nome,
          'sobrenome': membro.sobrenome,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('💾 ${membros.length} membros do grupo $grupoId salvos no SQLite');
  }

  // Carrega todos os grupos do SQLite
  Future<List<Group>> carregarGrupos() async {
    final db = await _dbHelper.database;
    await _ensureGrupoTables(db);

    final result = await db.query('grupos', orderBy: 'criado_em DESC');

    if (result.isEmpty) return [];

    final grupos = <Group>[];

    for (final row in result) {
      final grupo = Group(
        id: row['id'] as String,
        nome: row['nome'] as String,
        descricao: row['descricao'] as String?,
        codigo: row['codigo'] as String,
        aberto: (row['aberto'] as int) == 1,
        criadoPor: row['criado_por'] as String,
        criadoEm: DateTime.parse(row['criado_em'] as String),
        atualizadoEm: DateTime.parse(row['atualizado_em'] as String),
      );

      grupo.membros = await carregarMembrosGrupo(grupo.id);

      grupos.add(grupo);
    }

    log('📖 ${grupos.length} grupos carregados do SQLite');
    return grupos;
  }

  // Carrega os membros de um grupo específico
  Future<List<GroupMember>> carregarMembrosGrupo(String grupoId) async {
    final db = await _dbHelper.database;
    await _ensureGrupoTables(db);

    final result = await db.query(
      'grupos_membros',
      where: 'grupo_id = ?',
      whereArgs: [grupoId],
      orderBy: 'adicionado_em ASC',
    );

    if (result.isEmpty) return [];

    return result.map((row) {
      return GroupMember(
        id: row['id'] as int,
        grupoId: row['grupo_id'] as String,
        userId: row['user_id'] as String,
        papel: row['papel'] as String,
        adicionadoPor: row['adicionado_por'] as String,
        adicionadoEm: DateTime.parse(row['adicionado_em'] as String),
        nome: row['nome'] as String?,
        sobrenome: row['sobrenome'] as String?,
      );
    }).toList();
  }

  // Remove um grupo e seus membros do SQLite
  Future<void> removerGrupo(String grupoId) async {
    final db = await _dbHelper.database;
    await _ensureGrupoTables(db);

    await db
        .delete('grupos_membros', where: 'grupo_id = ?', whereArgs: [grupoId]);
    await db.delete('grupos', where: 'id = ?', whereArgs: [grupoId]);

    log('🗑️ Grupo $grupoId removido do SQLite');
  }

  // Atualiza um grupo específico
  Future<void> atualizarGrupo(Group grupo) async {
    final db = await _dbHelper.database;
    await _ensureGrupoTables(db);

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

    log('Grupo ${grupo.id} atualizado no SQLite');
  }
}
