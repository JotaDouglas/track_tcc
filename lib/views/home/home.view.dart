// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/helper/location.helper.dart';
import 'package:track_tcc_app/views/widgets/drawer.widget.dart';
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
      // Exibe alerta ou redireciona o usuário para configurações
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
      log("Permissões aceitas");
      if (mounted) {
        Locationhelper().checkGps(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey, // Adicionando a chave ao Scaffold
      appBar: AppBar(
        title: const Text(
          "Z E L O",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        automaticallyImplyLeading: false,
      ),

      drawer: DrawerWidget(authViewModel: authViewModel),
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
