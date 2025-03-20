import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/view/login/login.view.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Chave do Scaffold

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey, // Adicionando a chave ao Scaffold
      appBar: AppBar(
        title: const Text("Home"),
        automaticallyImplyLeading: false,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange[900]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.account_circle,
                      size: 50, color: Colors.white),
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
      ),
      body: Center(
        child: Text(authViewModel.loginUser?.email ?? "Sem e-mail"),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu,
                  color: _currentIndex == 1 ? Colors.orange[900] : Colors.grey),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer(); // Abre o Drawer
              },
            ),
            const SizedBox(width: 40), // Espaço para o botão central
            IconButton(
              icon: Icon(Icons.person,
                  color: _currentIndex == 0 ? Colors.orange[900] : Colors.grey),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Adicionar nova atividade
        },
        backgroundColor: Colors.orange[900],
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
