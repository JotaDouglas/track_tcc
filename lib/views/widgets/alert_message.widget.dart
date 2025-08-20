import 'dart:async';

import 'package:flutter/material.dart';

void showEmergencyConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _EmergencyDialog();
    },
  );
}

class _EmergencyDialog extends StatefulWidget {
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
          sendEmergencyAlert(context);
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

void sendEmergencyAlert(BuildContext context) {
  print("🚨 Alerta de perigo enviado!");
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Alerta de perigo enviado!", style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.red,
    ),
  );
}
