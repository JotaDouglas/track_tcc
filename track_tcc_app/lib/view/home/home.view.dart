import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _getBody(_currentIndex),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.person,
                  color: _currentIndex == 0 ? Colors.orange[900] : Colors.grey),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            const SizedBox(width: 40), // Espaço para o botão central
            IconButton(
              icon: Icon(Icons.menu,
                  color: _currentIndex == 1 ? Colors.orange[900] : Colors.grey),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
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

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return const Center(child: Text("Perfil"));
      case 1:
        return const Center(child: Text("Menu"));
      default:
        return const Center(child: Text("Página Inicial"));
    }
  }
}
