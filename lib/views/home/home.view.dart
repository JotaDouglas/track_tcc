import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/helper/location.helper.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';
import 'package:track_tcc_app/views/widgets/card_home.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestLocationPermission(context);
    });
  }

  Future<void> requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permissão necessária'),
            content: const Text(
                'Por favor, ative a permissão de localização nas configurações.'),
            actions: [
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Abrir configurações'),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        Locationhelper().checkGps(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<LoginViewModel>(context);
    final String nome = authViewModel.loginUser?.username ?? 'Usuário';

    return Scaffold(
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
                    Text(
                      'Olá, $nome 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Seja bem-vindo de volta!',
                      style: TextStyle(color: Colors.white70),
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
                    backgroundColor: WidgetStatePropertyAll(
                      Colors.orange[800],
                    ),
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
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                buildCard(
                  icon: Icons.navigation,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  color: Colors.orange[900],
                  label: "Compartilhar \n Posição",
                  onTap: () => GoRouter.of(context).push('/track'),
                ),
                buildCard(
                  icon: Icons.person,
                  label: "Perfil",
                  onTap: () => GoRouter.of(context).push('/user-perfil'),
                ),
                buildCard(
                  icon: Icons.person_search,
                  label: "Buscar\n Amigos",
                  onTap: () => GoRouter.of(context).push('/user-search'),
                ),
                buildCard(
                  icon: Icons.history,
                  label: "Histórico",
                  onTap: () => GoRouter.of(context).push('/historico-home'),
                ),
                buildCard(
                  icon: Icons.emergency_share,
                  label: "Acompanhar",
                  onTap: () => GoRouter.of(context).push('/location-share-home'),
                ),
                buildCard(
                  icon: Icons.settings,
                  label: "Configurações",
                  onTap: () => GoRouter.of(context).push('/settings-theme'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
