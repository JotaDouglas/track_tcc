import 'dart:convert';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/helper/database.helper.dart';
import 'package:track_tcc_app/model/place.model.dart';

class TrackRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> insertRota(PlaceModel location) async {
    final db = await _dbHelper.database;
    return await db.insert('rota', {
      'lat_inicial': location.latitude,
      'long_inicial': location.longitude,
      'data_hora_inicio': DateTime.now().toString(),
      'titulo': 'Trajeto #${DateTime.now().microsecondsSinceEpoch.toString()}',
    });
  }

  Future<void> updateRotaFinal(int rotaId, PlaceModel location) async {
    final db = await _dbHelper.database;
    await db.update(
      'rota',
      {
        'lat_final': location.latitude,
        'long_final': location.longitude,
        'data_hora_fim': DateTime.now().toString(),
      },
      where: 'id = ?',
      whereArgs: [rotaId],
    );
  }

  Future<void> insertRotaPoint(int rotaId, PlaceModel location) async {
    final db = await _dbHelper.database;
    await db.insert('rotas_points', {
      'id_rota': rotaId,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'data_hora': DateTime.now().toString(),
    });
  }

  Future<void> deleteRota(int rotaId) async {
    final db = await _dbHelper.database;

    // Deleta os pontos da rota
    await db.delete(
      'rotas_points',
      where: 'id_rota = ?',
      whereArgs: [rotaId],
    );

    // Deleta a rota principal
    await db.delete(
      'rota',
      where: 'id = ?',
      whereArgs: [rotaId],
    );
  }

  // (Opcional) Pegar pontos de uma rota específica
  Future<List<Map<String, dynamic>>> getRotaPoints(int rotaId) async {
    final db = await _dbHelper.database;
    return await db
        .query('rotas_points', where: 'id_rota = ?', whereArgs: [rotaId]);
  }

  Future<List<PlaceModel>> getAllRotas() async {
    final db = await _dbHelper.database;

    final result = await db.query('rota', orderBy: 'data_hora_inicio DESC');

    return result.map((row) => PlaceModel.fromMap(row)).toList();
  }

  Future<List<PlaceModel>> getPontosByRotaId(int rotaId) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'rotas_points',
      where: 'id_rota = ?',
      whereArgs: [rotaId],
      orderBy: 'data_hora ASC',
    );

    return result.map((row) => PlaceModel.fromMap(row)).toList();
  }

  Future<String> gerarJsonRotasComPontos(int id) async {
    final List<Map<String, dynamic>> rotasComPontosJson = [];

    final pontos = await getPontosByRotaId(id);

    rotasComPontosJson.add({
      'rota_id': id,
      'pontos': pontos.map((p) => p.toJson()).toList(),
    });

    return jsonEncode(rotasComPontosJson);
  }

  Future<bool> syncRotas(dynamic dados, int idRota) async {
    try {
      final response =
          await _supabase.from('rotas').insert(dados).select('id_rota');

      var value = response.first['id_rota'];

      // Verifica se houve erro
      if (value != null) {
        log('Insert bem-sucedido: $response');
        await updateIdRota(idRota, value);
        return true;
      }
    } catch (e) {
      log("erro encontrado: $e");
    }
    return false;
  }

  Future<void> updateIdRota(int rotaId, String idSistema) async {
    final db = await _dbHelper.database;
    await db.update(
      'rota',
      {
        'id_sistema': idSistema,
      },
      where: 'id = ?',
      whereArgs: [rotaId],
    );
  }

  Future<List<Map<String, dynamic>>> getRotasOnline(String id) async {
    try {
      final response = await _supabase.from('rotas').select().eq('user_id', id);
      log(response.toString());
      return response;
    } catch (e) {
      log("erro ao trazer dados: $e");
      return [];
    }
  }
}
