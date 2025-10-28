import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:track_tcc_app/helper/database.helper.dart';

class CercaRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> salvarCerca(String nome, List<LatLng> pontos) async {
    final db = await _dbHelper.database;
    final jsonPontos = jsonEncode(
      pontos.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    );

    // Se já existir uma cerca com esse nome, atualiza
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

  Future<void> deletarCerca(String nome) async {
    final db = await _dbHelper.database;
    await db.delete('cercas', where: 'nome = ?', whereArgs: [nome]);
  }
}
