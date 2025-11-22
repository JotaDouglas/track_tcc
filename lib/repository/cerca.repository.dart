import 'dart:convert';
import 'dart:developer';

import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/helper/database.helper.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';

class CercaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Tabela local existente (individual)
  Future<void> salvarCercaIndividual(String nome, List<LatLng> pontos) async {
    final db = await _dbHelper.database;
    final jsonPontos = jsonEncode(
      pontos.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    );

    final existente =
        await db.query('cercas', where: 'nome = ?', whereArgs: [nome]);

    if (existente.isNotEmpty) {
      await db.update(
        'cercas',
        {'pontos': jsonPontos},
        where: 'nome = ?',
        whereArgs: [nome],
      );
    } else {
      await db.insert('cercas', {'nome': nome, 'pontos': jsonPontos});
    }
  }

  Future<List<LatLng>?> carregarCercaIndividual(String nome) async {
    final db = await _dbHelper.database;
    final result =
        await db.query('cercas', where: 'nome = ?', whereArgs: [nome]);

    if (result.isEmpty) return null;

    final jsonData = jsonDecode(result.first['pontos'] as String) as List;
    return jsonData.map((p) => LatLng(p['lat'], p['lng'])).toList();
  }

  Future<List<String>> listarNomesCercasIndividuais() async {
    final db = await _dbHelper.database;
    final result = await db.query('cercas', columns: ['nome']);
    return result.map((e) => e['nome'] as String).toList();
  }

  Future<List<Group>> listarGrupos() async {
    final db = await _dbHelper.database;

    // Garante que as tabelas existem
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

    await _cercasCacheGrupoTable(db);

    // Busca grupos com LEFT JOIN para pegar o geo_data se existir
    final result = await db.rawQuery('''
      SELECT
        g.id,
        g.nome,
        g.descricao,
        g.aberto,
        g.codigo,
        g.criado_por,
        g.criado_em,
        g.atualizado_em,
        c.geo_data
      FROM grupos g
      LEFT JOIN cercas_cache_grupo c ON g.id = c.grupo_id
      ORDER BY g.criado_em DESC
    ''');

    if (result.isEmpty) return [];

    List<Group> grupsList = result.map((row) {
      // Decodifica o geo_data se existir
      dynamic geoData;
      if (row['geo_data'] != null) {
        try {
          geoData = jsonDecode(row['geo_data'] as String);
        } catch (e) {
          log('Erro ao decodificar geo_data do grupo ${row['id']}: $e');
          geoData = null;
        }
      }

      return Group(
        id: row['id'] as String,
        nome: row['nome'] as String,
        descricao: row['descricao'] as String?,
        codigo: row['codigo'] as String,
        aberto: (row['aberto'] as int) == 1,
        criadoPor: row['criado_por'] as String,
        criadoEm: DateTime.parse(row['criado_em'] as String),
        atualizadoEm: DateTime.parse(row['atualizado_em'] as String),
        geoData: geoData,
      );
    }).toList();

    return grupsList;
  }

  Future<void> deletarCercaIndividual(String nome) async {
    final db = await _dbHelper.database;
    await db.delete('cercas', where: 'nome = ?', whereArgs: [nome]);
  }

  /// Garante que a tabela de cache de grupo existe
  Future<void> _cercasCacheGrupoTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cercas_cache_grupo (
        grupo_id TEXT PRIMARY KEY,
        geo_data TEXT NOT NULL,
        atualizado_em TEXT,
        grupo_name TEXT,
        sync_status TEXT DEFAULT 'synced'
      );
    ''');
  }

  /// Insere ou atualiza o JSON de cercas do grupo (cache local)
  Future<void> cercasCacheGrupo(
    String grupoId,
    Map<String, List<LatLng>> cercas, {
    String? atualizadoEm,
    String? grupoName,
    String syncStatus = 'synced',
  }) async {
    try {
      final db = await _dbHelper.database;
      await _cercasCacheGrupoTable(db);

      final data = {
        'cercas': cercas.entries.map((e) {
          return {
            'nome': e.key,
            'pontos': e.value
                .map((p) => {'lat': p.latitude, 'lng': p.longitude})
                .toList(),
          };
        }).toList()
      };

      final jsonStr = jsonEncode(data);

      var res = await db.insert(
        'cercas_cache_grupo',
        {
          'grupo_id': grupoId,
          'grupo_name': grupoName,
          'geo_data': jsonStr,
          'atualizado_em': atualizadoEm ?? DateTime.now().toIso8601String(),
          'sync_status': syncStatus,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      log(res.toString());
    } catch (e) {
      log('Erro 1: $e');
    }
  }

  /// Carrega as cercas armazenadas localmente para o grupo
  Future<Map<String, List<LatLng>>> parseCercasCacheGrupo(
      List<Map<String, Object?>> res) async {
    if (res.isEmpty) return {};

    final jsonData = jsonDecode(res.first['geo_data'] as String);
    final List cercasList = jsonData['cercas'] ?? [];

    final Map<String, List<LatLng>> result = {};
    for (final item in cercasList) {
      final nome = item['nome'] ?? 'Sem nome';
      final pontos = (item['pontos'] as List)
          .map((p) => LatLng(p['lat'], p['lng']))
          .toList();
      result[nome] = pontos;
    }
    return result;
  }

  /// Carrega as cercas armazenadas localmente para o grupo
  Future<Map<String, List<LatLng>>> getCercasCacheGrupo(String grupoId) async {
    final db = await _dbHelper.database;
    await _cercasCacheGrupoTable(db);

    final res = await db.query(
      'cercas_cache_grupo',
      where: 'grupo_id = ?',
      whereArgs: [grupoId],
    );

    if (res.isEmpty) return {};

    final jsonData = jsonDecode(res.first['geo_data'] as String);
    final List cercasList = jsonData['cercas'] ?? [];

    final Map<String, List<LatLng>> result = {};
    for (final item in cercasList) {
      final nome = item['nome'] ?? 'Sem nome';
      final pontos = (item['pontos'] as List)
          .map((p) => LatLng(p['lat'], p['lng']))
          .toList();
      result[nome] = pontos;
    }
    return result;
  }

  /// Atualiza apenas uma cerca dentro do grupo (mantendo as outras)
  Future<void> salvarCercaNoCacheGrupo(
    String grupoId,
    String nome,
    List<LatLng> pontos, {
    String syncStatus = 'pending',
  }) async {
    final current = await getCercasCacheGrupo(grupoId);
    current[nome] = pontos;
    await cercasCacheGrupo(grupoId, current, syncStatus: syncStatus);
  }

  /// Remove uma cerca específica de um grupo
  Future<void> deletarCercaDoCacheGrupo(
    String grupoId,
    String nome, {
    String syncStatus = 'pending',
  }) async {
    final current = await getCercasCacheGrupo(grupoId);
    current.remove(nome);
    await cercasCacheGrupo(grupoId, current, syncStatus: syncStatus);
  }

  /// Marca um grupo como "pendente" para sincronizar depois
  Future<void> marcarGrupoPendenteSync(String grupoId) async {
    final db = await _dbHelper.database;
    await _cercasCacheGrupoTable(db);
    await db.update(
      'cercas_cache_grupo',
      {'sync_status': 'pending'},
      where: 'grupo_id = ?',
      whereArgs: [grupoId],
    );
  }

  /// Busca todos os grupos com alterações pendentes de sync
  Future<List<Map<String, dynamic>>> getGruposPendentes() async {
    final db = await _dbHelper.database;
    await _cercasCacheGrupoTable(db);
    return await db.query(
      'cercas_cache_grupo',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
  }
}

class CercaSupabaseRepository {
  final SupabaseClient _client;
  CercaSupabaseRepository(this._client);

  /// Busca as cercas de um grupo
  Future<Map<String, List<LatLng>>> getCercasDoGrupoRemoto(
      String grupoId) async {
    try {
      final res = await _client
          .from('cercas')
          .select('geo_data')
          .eq('grupo_id', grupoId)
          .maybeSingle();

      if (res == null || res['geo_data'] == null) return {};

      dynamic rawGeoData = res['geo_data'];
      if (rawGeoData is String) {
        try {
          rawGeoData = jsonDecode(rawGeoData);
        } catch (e) {
          log('Erro ao decodificar geo_data: $e');
          return {};
        }
      }
      if (rawGeoData is! Map<String, dynamic>) return {};

      final json = rawGeoData as Map<String, dynamic>;

      final cercas = <String, List<LatLng>>{};

      for (final item in (json['cercas'] ?? [])) {
        final nome = item['nome'] as String;
        final pontos = (item['pontos'] as List)
            .map((p) => LatLng(p['lat'], p['lng']))
            .toList();
        cercas[nome] = pontos;
      }
      return cercas;
    } catch (e) {
      log("Erro encontrado: $e");
      Map<String, List<LatLng>> item = {};
      return item;
    }
  }

  /// Cria a linha inicial no Supabase ao criar o grupo
  Future<void> criarRegistroCercasGrupoRemoto(
      String grupoId, String userId) async {
    await _client.from('cercas').insert({
      'grupo_id': grupoId,
      'geo_data': jsonEncode({'cercas': []}),
      'atualizado_por': userId,
    });
  }

  /// Atualiza o JSON de cercas
  Future<void> salvarCercasNoSupabase(
      String grupoId, Map<String, List<LatLng>> cercas, String userId) async {
    try {
      final data = {
        'cercas': cercas.entries
            .map((e) => {
                  'nome': e.key,
                  'pontos': e.value
                      .map((p) => {'lat': p.latitude, 'lng': p.longitude})
                      .toList(),
                })
            .toList()
      };

      await _client.from('cercas').update({
        'geo_data': jsonEncode(data),
        'atualizado_por': userId,
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('grupo_id', grupoId);
    } catch (e) {
      throw ("Erro ao salvar: $e");
    }
  }
}
