import 'package:track_tcc_app/helper/database.helper.dart';
import 'package:track_tcc_app/model/place.model.dart';

class TrackRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

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
}
