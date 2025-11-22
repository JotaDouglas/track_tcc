import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> enviarNotificacaoOneSignal({
  required List<String> playerId,
  required String titulo,
  required String mensagem,
}) async {
  String appId = dotenv.env['OPEN_SIGNAL_APP_ID']!;
  String restApiKey = dotenv.env['OPEN_SIGNAL_REST_API_KEY']!;

  final Dio dio = Dio();

  try {
    final response = await dio.post(
      'https://onesignal.com/api/v1/notifications',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $restApiKey',
        },
      ),
      data: {
        'app_id': appId,
        'include_player_ids': playerId,
        'headings': {'en': titulo},
        'contents': {'en': mensagem},
        'android_accent_color': 'FFE65100',
      },
    );

    if (response.statusCode == 200) {
      log('Notificação enviada com sucesso!');
    } else {
      log('Erro ao enviar: ${response.statusCode} - ${response.data}');
    }
  } catch (e) {
    log('Erro na requisição: $e');
  }
}
