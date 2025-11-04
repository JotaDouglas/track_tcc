import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/amizade.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/cerca.viewmodel.dart';
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
  void initState() {
    super.initState();
    loadcercas();
  }

  Future<void> loadcercas() async {
    final cercaVM = Provider.of<CercaViewModel>(context, listen: false);
    await cercaVM.listarCercas();
    await cercaVM.carregarTodasCercasLocais();
  }

  @override
  Widget build(BuildContext context) {
    final trackVM = Provider.of<TrackingViewModel>(context);
    final authViewModel = Provider.of<LoginViewModel>(context);
    final amizadeVM = Provider.of<AmizadeViewModel>(context);
    final cercaVM = Provider.of<CercaViewModel>(context, listen: false);

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
        title: const Text(
          "Tracking",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.orange[900],
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Observer(
            builder: (_) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCercaSelector(context, cercaVM, trackVM),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange[900]?.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.assistant_navigation,
                    size: trackVM.trackingMode ? 80 : 60,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 24),
                if (!trackVM.trackingMode) ...[
                  Text(
                    'Modo de Rastreamento',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModeButton(
                        context,
                        label: 'Econômico',
                        color: Colors.green,
                        isSelected: trackVM.trackingInterval == 60,
                        onTap: () =>
                            setState(() => trackVM.setTrackingInterval(60)),
                      ),
                      _buildModeButton(
                        context,
                        label: 'Eficiente',
                        color: Colors.orange,
                        isSelected: trackVM.trackingInterval == 30,
                        onTap: () =>
                            setState(() => trackVM.setTrackingInterval(30)),
                      ),
                      _buildModeButton(
                        context,
                        label: 'Preciso',
                        color: Colors.red,
                        isSelected: trackVM.trackingInterval == 10,
                        onTap: () =>
                            setState(() => trackVM.setTrackingInterval(10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getModeDescription(trackVM.trackingInterval),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                ],
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
                            backgroundColor: Colors.blue[700]?.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                            backgroundColor: Colors.red[700]?.withOpacity(0.9),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange[900]!,
                        Colors.orange[600]!,
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await _requestLocationPermission(context);
                      await trackVM.startTracking(nome);
                    },
                    child: Text(
                      trackVM.trackingMode ? 'Parar' : 'Iniciar',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildModeButton(
  BuildContext context, {
  required String label,
  required Color color,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildCercaSelector(BuildContext context, CercaViewModel cerca, TrackingViewModel track) {
  return Observer(
    builder: (context) {
      // Exibe somente se houver cercas carregadas
      if (cerca.cercasMap.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Nenhuma cerca disponível para este grupo.",
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "Selecione a cerca para monitorar",
            border: OutlineInputBorder(),
          ),
          value: cerca.cercaSelecionada,
          items: cerca.cercasMap.keys.map((nome) {
            return DropdownMenuItem(
              value: nome,
              child: Text(nome),
            );
          }).toList(),
          onChanged: (value) {
            cerca.cercaSelecionada = value;
            track.cercaSelecionada = value;
          },
        ),
      );
    },
  );
}

String _getModeDescription(int interval) {
  switch (interval) {
    case 60:
      return 'Atualiza a cada 60 segundos — maior economia de bateria.';
    case 30:
      return 'Atualiza a cada 30 segundos — equilíbrio entre precisão e bateria.';
    case 10:
      return 'Atualiza a cada 10 segundos — localização em tempo real e maior consumo de bateria.';
    default:
      return '';
  }
}
