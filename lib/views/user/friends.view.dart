import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/viewmodel/amizade.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  AmizadeViewModel amizadeVM = AmizadeViewModel();

  @override
  void initState() {
    super.initState();
    // Delay para garantir que o contexto esteja disponível
    Future.microtask(() {
      if (mounted) {
        amizadeVM = Provider.of<AmizadeViewModel>(context, listen: false);
      }
      readUsers();
    });
  }

  readUsers() async {
    await amizadeVM.readMyFriends(onlyFriends: true);
  }

  @override
  Widget build(BuildContext context) {
    amizadeVM = Provider.of<AmizadeViewModel>(context);
    final authViewModel = Provider.of<LoginViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MEUS AMIGOS",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.person_add_alt_1,
                      color: Colors.orange[800],
                    ),
                    label: Text(
                      'Solicitações',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                    onPressed: () => GoRouter.of(context).push('/user-friends-requests'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.search,
                      color: Colors.orange[800],
                    ),
                    label: Text(
                      'Buscar Amigos',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                    onPressed: () => GoRouter.of(context).push('/user-search'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Observer(
            builder: (context) => Expanded(
              child: (amizadeVM.friends.isNotEmpty) ? ListView.builder(
                itemCount: amizadeVM.friends.length,
                itemBuilder: (context, index) {
                  final friend = amizadeVM.friends[index]['remetente']['user_id'] == authViewModel.loginUser!.uidUsuario ?amizadeVM.friends[index]['remetente'] :amizadeVM.friends[index]['destinatario'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange[800],
                          child: Text(friend['nome']![0],
                              style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(friend['nome']!, style: TextStyle(fontWeight: FontWeight.bold),),
                        subtitle: Text(friend['email']!),
                        onTap: () {
                          // Ação ao clicar no amigo
                        },
                      ),
                    ),
                  );
                },
              ): Center(child: Text("Ainda não possui amizades"),)
            ),
          ),
        ],
      ),
    );
  }
}
