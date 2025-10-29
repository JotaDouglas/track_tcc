import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/amizade.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';
import 'package:track_tcc_app/views/widgets/alert_message.widget.dart';
import 'package:track_tcc_app/views/widgets/quick_message.widget.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({super.key});

  @override
  State<TrackPage> createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  Future<void> _requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.status;
    if (!status.isGranted) status = await Permission.location.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permissão necessária'),
          content:
              const Text('Ative a permissão de localização nas configurações.'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Abrir configurações'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackVM = Provider.of<TrackingViewModel>(context);
    final authViewModel = Provider.of<LoginViewModel>(context);
    final amizadeVM = Provider.of<AmizadeViewModel>(context);

    final nome = authViewModel.loginUser?.username ?? 'Sem nome';
    final nomeCompleto =
        "${authViewModel.loginUser?.username}${authViewModel.loginUser?.sobrenome ?? ''}";

    List<String> amigos = [];
    // supondo que amizadeVM.friends seja uma lista de maps
    for (var amigo in amizadeVM.friends) {
      String messageid =
          amigo['remetente']['email'] != authViewModel.loginUser!.email
              ? amigo['remetente']['message_id']
              : amigo['destinatario']['message_id'];

      amigos.add(messageid);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("TRACKING", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Observer(
            builder: (_) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assistant_navigation,
                  size: trackVM.trackingMode ? 100 : 80,
                  color: Colors.orange[900],
                ),
                const SizedBox(height: 24),
                Text(
                  trackVM.trackingMode
                      ? 'Rastreamento em andamento'
                      : 'Toque para iniciar o compartilhamento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange[900],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (trackVM.trackingMode) ...[
                  Text(
                    'Distância: ${trackVM.distanceMeters.toStringAsFixed(1)} m',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trackVM.addressLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showQuickMessageBottomSheet(
                              context,
                              amigos,
                              nomeCompleto,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: const Icon(Icons.message, color: Colors.white),
                          label: const Text("Mensagem rápida",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              showEmergencyConfirmationDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: const Icon(Icons.warning_amber_rounded,
                              color: Colors.white),
                          label: const Text("Situação de Perigo",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.orange[900],
                  ),
                  onPressed: () async {
                    await _requestLocationPermission(context);
                    await trackVM.startTracking(nome);
                  },
                  child: Text(
                    trackVM.trackingMode ? 'PARAR' : 'INICIAR',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
