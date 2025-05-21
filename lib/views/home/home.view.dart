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
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
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
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                buildCard(
                  icon: Icons.route,
                  label: "Track",
                  onTap: () => GoRouter.of(context).push('/track'),
                ),
                buildCard(
                  icon: Icons.person,
                  label: "Perfil",
                  onTap: () => GoRouter.of(context).push('/user-perfil'),
                ),
                buildCard(
                  icon: Icons.person_search,
                  label: "Buscar Amigos",
                  onTap: () => GoRouter.of(context).push('/user-search'),
                ),
                buildCard(
                  icon: Icons.map,
                  label: "Mapa",
                  onTap: () => GoRouter.of(context).push('/historic'),
                ),
                buildCard(
                  icon: Icons.history,
                  label: "Histórico",
                  onTap: () => GoRouter.of(context).push('/historico-home'),
                ),
                buildCard(
                  icon: Icons.logout,
                  label: "Sair",
                  onTap: () {
                    authViewModel.logout();
                    GoRouter.of(context).pushReplacement('/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
}
