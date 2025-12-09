import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> enviarNotificacaoOneSignal({
  required List<String> playerId,
  required String titulo,
  required String mensagem,
  String? ignorarPlayerId, // ID do usuário que não deve receber a notificação
}) async {
  String appId = dotenv.env['OPEN_SIGNAL_APP_ID']!;
  String restApiKey = dotenv.env['OPEN_SIGNAL_REST_API_KEY']!;

  final Dio dio = Dio();

  // Filtra a lista de playerIds para remover o ID do usuário atual
  List<String> playerIdsFiltrados = playerId;
  if (ignorarPlayerId != null && ignorarPlayerId.isNotEmpty) {
    playerIdsFiltrados = playerId.where((id) => id != ignorarPlayerId).toList();
    log('Removido playerId $ignorarPlayerId da lista de notificações');
  }

  // Se não houver destinatários após a filtragem, não envia
  if (playerIdsFiltrados.isEmpty) {
    log('Nenhum destinatário para enviar notificação após filtragem');
    return;
  }

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
        'include_player_ids': playerIdsFiltrados,
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
