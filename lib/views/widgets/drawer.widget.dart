import 'package:flutter/material.dart';
import 'package:track_tcc_app/views/login/login.view.dart';
import 'package:track_tcc_app/views/track/tracking.view.dart';
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
                  authViewModel.loginUser?.email ?? "Usuário",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Track"),
            onTap: () {
              authViewModel.logout();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrackPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Logout"),
            onTap: () {
              authViewModel.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
