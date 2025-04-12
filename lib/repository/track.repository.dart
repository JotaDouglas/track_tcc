import 'package:track_tcc_app/helper/database.helper.dart';

class TrackRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertPosition({
    required String pontoInicial,
    required String pontoFinal,
    required String dataHora,
    required String distancia,
    required String titulo,
    required List<Map<String, String>> pontos,
  }) async {
    final db = await _dbHelper.database;

    // Inserir a rota principal
    final rotaId = await db.insert('rota', {
      'ponto_inicial': pontoInicial,
      'ponto_final': pontoFinal,
      'data_hora': dataHora,
      'distancia': distancia,
      'titulo': titulo,
    });

    // Inserir os pontos ligados a essa rota
    for (final ponto in pontos) {
      await db.insert('rotas_points', {
        'id_rota': rotaId,
        'latitude': ponto['latitude']!,
        'longitude': ponto['longitude']!,
        'data_hora': ponto['data_hora']!,
      });
    }
  }
}
