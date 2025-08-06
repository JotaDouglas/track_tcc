import 'dart:developer';

import 'package:dio/dio.dart';

Future<void> enviarNotificacaoOneSignal({
  required List<String> playerId,
  required String titulo,
  required String mensagem,
}) async {
  const String appId = '5eb8b243-0349-434e-a940-ba558fd0663c';
  const String restApiKey =
      'os_v2_app_l24leqydjfbu5kkaxjky7udghqfbn6r7znaejkf52l6tjcw662p4qy5ko3rpcdm4pppqzohssxw7vwfnl3u2zmilesp6iv4cqq2sq2i';

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
      log('✅ Notificação enviada com sucesso!');
    } else {
      log('⚠️ Erro ao enviar: ${response.statusCode} - ${response.data}');
    }
  } catch (e) {
    log('❌ Erro na requisição: $e');
  }
}
