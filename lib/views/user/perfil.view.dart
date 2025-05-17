import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  @override
  Widget build(BuildContext context) {
    final int amigos = 120;
    final int rotasCompartilhadas = 45;
    final double totalKm = 327.8;

    final authViewModel = Provider.of<LoginViewModel>(context);
    var user = authViewModel.loginUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[900],
        centerTitle: true,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto de Perfil (ícone)
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.orange[900],
                  child:
                      const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Nome e sobrenome
                Text(
                  user?.username != null && user?.sobrenome != null
                      ? "${user?.username} ${user?.sobrenome}"
                      : "User1234",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                // // Localização
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Icon(Icons.location_on, size: 16, color: Colors.grey),
                //     const SizedBox(width: 4),
                //     Text(
                //       localizacao,
                //       style: const TextStyle(color: Colors.grey),
                //     ),
                //   ],
                // ),

                const SizedBox(height: 16),

                // Botão de ação (opcional)

                // Contagens
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$amigos',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text('Amigos'),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Text(
                          '$rotasCompartilhadas',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text('Trajetos', textAlign: TextAlign.center),
                      ],
                    ),
                    const SizedBox(width: 40),
                    Column(
                      children: [
                        Text(
                          totalKm.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const Text('Km', textAlign: TextAlign.center),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () {
                            GoRouter.of(context).push('/user-perfil-edit');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange[900]!),
                            foregroundColor: Colors.orange[900],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          label: const Text("Editar Perfil"),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.person_add_alt_1, size: 18),
                          label: const Text("Adicionar amigo"),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange[900]!),
                            foregroundColor: Colors.orange[900],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Sobre mim
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SOBRE MIM',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange[900]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user?.bio != null && user!.bio!.isNotEmpty
                  ? user.bio!
                  : "Este é o meu espaço onde posso falar sobre mim",
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
