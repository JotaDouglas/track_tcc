import 'dart:convert';
import 'dart:developer';

import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/helper/database.helper.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';

class CercaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 🔹 Tabela local existente (individual)
  Future<void> salvarCerca(String nome, List<LatLng> pontos) async {
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

  Future<List<LatLng>?> carregarCerca(String nome) async {
    final db = await _dbHelper.database;
    final result =
        await db.query('cercas', where: 'nome = ?', whereArgs: [nome]);

    if (result.isEmpty) return null;

    final jsonData = jsonDecode(result.first['pontos'] as String) as List;
    return jsonData.map((p) => LatLng(p['lat'], p['lng'])).toList();
  }

  Future<List<String>> listarCercas() async {
    final db = await _dbHelper.database;
    final result = await db.query('cercas', columns: ['nome']);
    return result.map((e) => e['nome'] as String).toList();
  }
  Future listarGrupos() async {
    final db = await _dbHelper.database;
    final result = await db.query('cercas_cache_grupo');
    List<Group> grupsList = (result.map((r) => Group.fromJson(r)).toList());
    return grupsList;
  }

  Future<void> deletarCerca(String nome) async {
    final db = await _dbHelper.database;
    await db.delete('cercas', where: 'nome = ?', whereArgs: [nome]);
  }

  // ======================================================================
  // 🔹 NOVA SEÇÃO: Sincronização com Supabase (Cercas de Grupo)
  // ======================================================================

  /// Garante que a tabela de cache de grupo existe
  Future<void> _ensureGrupoTable(Database db) async {
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
  Future<void> upsertCercasGrupo(
    String grupoId,
    Map<String, List<LatLng>> cercas, {
    String? atualizadoEm,
    String? grupoName,
    String syncStatus = 'synced',
  }) async {
    try {
      
    final db = await _dbHelper.database;
    await _ensureGrupoTable(db);

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
  Future<Map<String, List<LatLng>>> convertCercasGrupo(List<Map<String, Object?>> res) async {
    //Tranforma grupos em objetos
    List<Group> grupos = [];
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
  Future<Map<String, List<LatLng>>> getCercasGrupo(String grupoId) async {
    final db = await _dbHelper.database;
    await _ensureGrupoTable(db);

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
  Future<void> saveSingleCercaLocal(
    String grupoId,
    String nome,
    List<LatLng> pontos, {
    String syncStatus = 'pending',
  }) async {
    final current = await getCercasGrupo(grupoId);
    current[nome] = pontos;
    await upsertCercasGrupo(grupoId, current, syncStatus: syncStatus);
  }

  /// Remove uma cerca específica de um grupo
  Future<void> deleteCercaLocal(
    String grupoId,
    String nome, {
    String syncStatus = 'pending',
  }) async {
    final current = await getCercasGrupo(grupoId);
    current.remove(nome);
    await upsertCercasGrupo(grupoId, current, syncStatus: syncStatus);
  }

  /// Marca um grupo como "pendente" para sincronizar depois
  Future<void> markGrupoPending(String grupoId) async {
    final db = await _dbHelper.database;
    await _ensureGrupoTable(db);
    await db.update(
      'cercas_cache_grupo',
      {'sync_status': 'pending'},
      where: 'grupo_id = ?',
      whereArgs: [grupoId],
    );
  }

  /// Busca todos os grupos com alterações pendentes de sync
  Future<List<Map<String, dynamic>>> getPendingGroups() async {
    final db = await _dbHelper.database;
    await _ensureGrupoTable(db);
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
  Future<Map<String, List<LatLng>>> getCercasPorGrupo(String grupoId) async {
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
          print('Erro ao decodificar geo_data: $e');
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
  Future<void> criarRegistroGrupo(String grupoId, String userId) async {
    await _client.from('cercas').insert({
      'grupo_id': grupoId,
      'geo_data': jsonEncode({'cercas': []}),
      'atualizado_por': userId,
    });
  }

  /// Atualiza o JSON de cercas
  Future<void> salvarCercas(
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
