import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/amizade.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class FriendRequestsView extends StatefulWidget {
  const FriendRequestsView({super.key});

  @override
  State<FriendRequestsView> createState() => _FriendRequestsViewState();
}

class _FriendRequestsViewState extends State<FriendRequestsView> {
  late AmizadeViewModel amizadeVM;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        amizadeVM = Provider.of<AmizadeViewModel>(context, listen: false);
        readRequests();
      }
    });
  }

  readRequests() async {
    await amizadeVM.readMyFriends(onlyFriends: false); // Aqui busca solicitações
  }

  @override
  Widget build(BuildContext context) {
    amizadeVM = Provider.of<AmizadeViewModel>(context);
    final authViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SOLICITAÇÕES DE AMIZADE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Observer(
        builder: (context) => amizadeVM.friends.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: amizadeVM.friends.length,
                itemBuilder: (context, index) {
                  final solicitacao = amizadeVM.friends[index];
                  final usuario = solicitacao['remetente']['user_id'] ==
                          authViewModel.loginUser!.uidUsuario
                      ? solicitacao['destinatario']
                      : solicitacao['remetente'];

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange[800],
                              child: Text(
                                usuario['nome']![0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              usuario['nome']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(usuario['email'] ?? ''),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[800],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: const Icon(Icons.check,
                                    color: Colors.white),
                                label: const Text(
                                  "Aceitar",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  // amizadeVM.aceitarSolicitacao(
                                  //     solicitacao['id']);
                                },
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon: const Icon(Icons.close,
                                    color: Colors.white),
                                label: const Text(
                                  "Recusar",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  // amizadeVM.recusarSolicitacao(
                                  //     solicitacao['id']);
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: Text("Nenhuma solicitação pendente"),
              ),
      ),
    );
  }
}
