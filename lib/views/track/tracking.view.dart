import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/model/grupo/grupo.model.dart';
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
  int _currentStep = 0;

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
    _checkTrackingStatus();
  }

  void _checkTrackingStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trackVM = Provider.of<TrackingViewModel>(context, listen: false);
      if (trackVM.trackingMode) {
        setState(() {
          _currentStep = 2;
        });
      }
    });
  }

  Future<void> loadcercas() async {
    final cercaVM = Provider.of<CercaViewModel>(context, listen: false);
    await cercaVM.listarCercas();
    await cercaVM.listarGrupos();
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
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Observer(
                  builder: (_) => _buildStepContent(
                    context,
                    trackVM,
                    cercaVM,
                    amigos,
                    nomeCompleto,
                    nome,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: const Color(0xFF2A2A2A),
      child: Row(
        children: [
          _buildStep(1, 'Cerca', _currentStep >= 0),
          _buildStepLine(_currentStep >= 1),
          _buildStep(2, 'Modo', _currentStep >= 1),
          _buildStepLine(_currentStep >= 2),
          _buildStep(3, 'Tracking', _currentStep >= 2),
        ],
      ),
    );
  }

  Widget _buildStep(int stepNumber, String label, bool isActive) {
    final isCompleted = _currentStep > stepNumber - 1;
    final isCurrent = _currentStep == stepNumber - 1;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.orange[900]
                : Colors.orange[900]?.withOpacity(0.3),
            border: Border.all(
              color: isCurrent ? Colors.orange[600]! : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted && !isCurrent
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
        color: isActive
            ? Colors.orange[900]
            : Colors.orange[900]?.withOpacity(0.3),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    TrackingViewModel trackVM,
    CercaViewModel cercaVM,
    List<String> amigos,
    String nomeCompleto,
    String nome,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(context, cercaVM, trackVM);
      case 1:
        return _buildStep2(context, trackVM);
      case 2:
        return _buildStep3(context, trackVM, amigos, nomeCompleto, nome);
      default:
        return Container();
    }
  }

  // Step 1: Seleção de Cerca
  Widget _buildStep1(
      BuildContext context, CercaViewModel cercaVM, TrackingViewModel track) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange[900]?.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.groups,
                  size: 80,
                  color: Colors.orange[900],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Selecione o Grupo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Escolha qual grupo você deseja que possa monitorar durante o rastreamento',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Observer(
                builder: (context) {
                  if (cercaVM.cercasMap.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Nenhum grupo disponível.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // decoration: BoxDecoration(
                    //   color: const Color(0xFF2A2A2A),
                    //   borderRadius: BorderRadius.circular(16),
                    //   border: Border.all(
                    //     color: Colors.orange[900]?.withOpacity(0.3) ?? Colors.grey,
                    //   ),
                    // ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Grupo",
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.white70),
                      ),
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      value: cercaVM.grupoSelecionado?.nome,
                      items: cercaVM.gruposNames.map((grupo) {
                        return DropdownMenuItem(
                          value: grupo.nome,
                          child: Text(grupo.nome),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value?.isNotEmpty == true) {
                          Group grupoSelected = cercaVM.gruposNames
                              .firstWhere((g) => g.nome == value);
                          cercaVM.grupoSelecionado = grupoSelected;
                          track.grupoSelecionado = grupoSelected;
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // const Spacer(),
        _buildNavigationButtons(
          showBack: false,
          showNext: true,
          onNext: () {
            setState(() {
              _currentStep = 1;
            });
          },
        ),
      ],
    );
  }

  // Step 2: Seleção de Modo
  Widget _buildStep2(BuildContext context, TrackingViewModel trackVM) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.orange[900]?.withOpacity(0.1),
          ),
          child: Icon(
            Icons.speed,
            size: 80,
            color: Colors.orange[900],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Modo de Rastreamento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Escolha o intervalo de atualização da sua localização',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildModeButton(
              context,
              label: 'Econômico',
              color: Colors.green,
              isSelected: trackVM.trackingInterval == 60,
              onTap: () => setState(() => trackVM.setTrackingInterval(60)),
            ),
            _buildModeButton(
              context,
              label: 'Eficiente',
              color: Colors.orange,
              isSelected: trackVM.trackingInterval == 30,
              onTap: () => setState(() => trackVM.setTrackingInterval(30)),
            ),
            _buildModeButton(
              context,
              label: 'Preciso',
              color: Colors.red,
              isSelected: trackVM.trackingInterval == 10,
              onTap: () => setState(() => trackVM.setTrackingInterval(10)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          _getModeDescription(trackVM.trackingInterval),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        _buildNavigationButtons(
          showBack: false,
          showNext: true,
          onNext: () {
            setState(() {
              _currentStep = 2;
            });
          },
        ),
      ],
    );
  }

  // Step 3: Controles de Tracking
  Widget _buildStep3(
    BuildContext context,
    TrackingViewModel trackVM,
    List<String> amigos,
    String nomeCompleto,
    String nome,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
        const SizedBox(height: 32),
        if (trackVM.trackingMode) ...[
          const Text(
            'Rastreamento Ativo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 32),
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
                  onPressed: () => showEmergencyConfirmationDialog(context),
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
        ] else ...[
          const Text(
            'Iniciar Rastreamento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Toque no botão abaixo para começar a compartilhar sua localização',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
        const Spacer(),
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
              if (!trackVM.trackingMode) {
                setState(() {
                  _currentStep = 0;
                });
              }
            },
            child: Text(
              trackVM.trackingMode
                  ? 'Parar Rastreamento'
                  : 'Iniciar Rastreamento',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!trackVM.trackingMode)
          TextButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            child: const Text(
              'Voltar',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons({
    required bool showBack,
    required bool showNext,
    VoidCallback? onBack,
    VoidCallback? onNext,
  }) {
    return Row(
      children: [
        if (showBack)
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange[900]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Voltar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (showBack && showNext) const SizedBox(width: 16),
        if (showNext)
          Expanded(
            child: Container(
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
                onPressed: onNext,
                child: const Text(
                  'Próximo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
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
