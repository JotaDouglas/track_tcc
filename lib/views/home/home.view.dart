import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/configs/theme_settings.dart';
import 'package:track_tcc_app/viewmodel/amizade.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';
import 'package:track_tcc_app/views/widgets/card_home.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _localizacaoAtiva = false;

  @override
  void initState() {
    super.initState();
    _verificarPermissaoLocalizacao();
    _loginMessagem();
  }

  Future<void> _loginMessagem() async {
    await Future.delayed(Duration(seconds: 1));
    var playerId = OneSignal.User.pushSubscription.id;
    log("💡 $playerId");
  }

  Future<void> _verificarPermissaoLocalizacao() async {
    final status = await Permission.location.status;
    setState(() {
      _localizacaoAtiva = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<LoginViewModel>(context);
    final String nome = authViewModel.loginUser?.username ?? 'Usuário';
    final amizadeVM = Provider.of<AmizadeViewModel>(context);
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.mode == ThemeMode.dark;
    amizadeVM.readMyFriends();

    return SafeArea(
      top: false,
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 100, left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange[900],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Olá, $nome 👋',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: const Text(
                              'Seja bem-vindo de volta!',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 35,
                  right: 10,
                  child: FilledButton(
                    onPressed: () {
                      authViewModel.logout();
                      GoRouter.of(context).pushReplacement('/login');
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.orange[800]),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 5),
                        Text("Sair", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 35,
                  left: 10,
                  child: FilledButton(
                    onPressed: () => provider.toggleTheme(!isDark),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.orange[800]),
                    ),
                    child: Row(
                      children: [
                        Icon(
                            isDark
                                ? Icons.nightlight_round_outlined
                                : Icons.sunny,
                            color: Colors.white),
                        SizedBox(width: 5),
                        Text(isDark ? "Escuro" : "Claro",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 10, top: 10),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildCard(
                    icon: Icons.navigation,
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    color: Colors.orange[900],
                    label: "Compartilhar \n Viajem",
                    onTap: () => GoRouter.of(context).push('/track'),
                  ),
                  buildCard(
                    icon: Icons.person,
                    label: "Perfil",
                    onTap: () => GoRouter.of(context).push('/user-perfil'),
                  ),
                  buildCard(
                    icon: Icons.history,
                    label: "Histórico",
                    onTap: () => GoRouter.of(context).push('/historico-home'),
                  ),
                  buildCard(
                    icon: Icons.emergency_share,
                    label: "Acompanhar",
                    onTap: () =>
                        GoRouter.of(context).push('/location-share-home'),
                  ),
                  buildCard(
                    icon: Icons.run_circle_outlined,
                    label: "Cerca",
                    onTap: () => GoRouter.of(context).push('/cerca-menu'),
                  ),
                  buildCard(
                    icon: Icons.groups_2_sharp,
                    label: "Grupos",
                    onTap: () => GoRouter.of(context).push('/grupos'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
