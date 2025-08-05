import 'package:flutter/material.dart';

void showQuickMessageBottomSheet(BuildContext context) {
  final List<Map<String, dynamic>> quickMessages = [
    {'icon': Icons.build, 'label': "Pneu furado", 'color': Colors.deepOrange},
    {
      'icon': Icons.local_gas_station,
      'label': "Sem gasolina",
      'color': Colors.amber
    },
    {
      'icon': Icons.traffic,
      'label': "Trânsito lento",
      'color': Colors.blueGrey
    },
    {
      'icon': Icons.restaurant,
      'label': "Parei para comer",
      'color': Colors.teal
    },
    {'icon': Icons.wc, 'label': "Parei no banheiro", 'color': Colors.purple},
    {
      'icon': Icons.signal_wifi_off,
      'label': "Sem sinal",
      'color': Colors.indigo
    },
    {'icon': Icons.schedule, 'label': "Vou me atrasar", 'color': Colors.brown},
    {
      'icon': Icons.bedtime,
      'label': "Parei para descansar",
      'color': Colors.cyan
    },
    {'icon': Icons.home, 'label': "Já estou chegando", 'color': Colors.green},
    {
      'icon': Icons.battery_alert,
      'label': "Bateria baixa",
      'color': Colors.red
    },
  ];

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled:
        true, // permite que o bottom sheet seja mais alto se necessário
    builder: (BuildContext context) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: quickMessages.map((item) {
                return ListTile(
                  leading: Icon(item['icon'], color: item['color']),
                  title: Text(item['label']),
                  onTap: () {
                    Navigator.pop(context);
                    _handleQuickMessage(context, item['label']);
                  },
                );
              }).toList(),
            ),
          ),
        ),
      );
    },
  );
}

void _handleQuickMessage(BuildContext context, String message) {
  print("Mensagem rápida selecionada: $message");

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Mensagem enviada: $message")),
  );
}
