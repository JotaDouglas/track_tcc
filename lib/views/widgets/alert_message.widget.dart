import 'dart:async';

import 'package:flutter/material.dart';
import 'package:track_tcc_app/utils/message.util.dart';

void showEmergencyConfirmationDialog(
  BuildContext context, {
  required List<String> messageIds,
  required String nomeCompleto,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _EmergencyDialog(
        messageIds: messageIds,
        nomeCompleto: nomeCompleto,
      );
    },
  );
}

class _EmergencyDialog extends StatefulWidget {
  final List<String> messageIds;
  final String nomeCompleto;

  const _EmergencyDialog({
    required this.messageIds,
    required this.nomeCompleto,
  });

  @override
  State<_EmergencyDialog> createState() => _EmergencyDialogState();
}

class _EmergencyDialogState extends State<_EmergencyDialog> {
  int secondsRemaining = 5;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (mounted) {
        setState(() {
          secondsRemaining--;
        });
        if (secondsRemaining == 0) {
          t.cancel();
          Navigator.of(context).pop();
          sendEmergencyAlert(
            context,
            messageIds: widget.messageIds,
            nomeCompleto: widget.nomeCompleto,
          );
        }
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Confirmar Alerta',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'O alerta de perigo será enviado em:',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (5 - secondsRemaining) / 5,
                strokeWidth: 6,
                color: Colors.red,
              ),
              Text(
                '$secondsRemaining',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            timer?.cancel();
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

Future<void> sendEmergencyAlert(
  BuildContext context, {
  required List<String> messageIds,
  required String nomeCompleto,
}) async {
  print("🚨 Alerta de perigo enviado!");

  try {
    // Envia notificação de emergência para todos os membros do grupo
    await enviarNotificacaoOneSignal(
      playerId: messageIds,
      titulo: '🚨 ALERTA DE EMERGÊNCIA!',
      mensagem: '$nomeCompleto está em PERIGO! Verifique a localização imediatamente.',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Alerta de emergência enviado com sucesso!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    print("❌ Erro ao enviar alerta de emergência: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao enviar alerta: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[900],
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
