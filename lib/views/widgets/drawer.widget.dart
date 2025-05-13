import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
    required this.authViewModel,
  });

  final LoginViewModel authViewModel;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange[900]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.account_circle, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  authViewModel.loginUser?.username ?? "Usuário",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text("Track"),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/track');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Mapa"),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/historic');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("Historico"),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/historico-home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Logout"),
            onTap: () {
              authViewModel.logout();
              GoRouter.of(context).pushReplacement('/login');
            },
          ),
        ],
      ),
    );
  }
}
