import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:track_tcc_app/helper/DateConversion.helper.dart';
import 'package:track_tcc_app/model/place.model.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';
import 'package:track_tcc_app/views/historicos/historico_map.view.dart';

class RotasPage extends StatefulWidget {
  const RotasPage({super.key});

  @override
  State<RotasPage> createState() => _RotasPageState();
}

class _RotasPageState extends State<RotasPage> with TickerProviderStateMixin {
  final TrackingViewModel trackViewModel = TrackingViewModel();
  List<PlaceModel> rotas = [];
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    loadRotas();
  }

  Future<void> loadRotas() async {
    final result = await trackViewModel.getAllRotas();
    final rotasOnline = await trackViewModel.getRotasOnline();
    setState(() {
      rotas = result;
    });
  }

  Future<void> deletarRota(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Rota"),
        content: const Text("Tem certeza que deseja excluir esta rota?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await trackViewModel.removeRota(id);
      await loadRotas();
    }
  }

  @override
  Widget build(BuildContext context) {
    tabController = TabController(length: 2, vsync: this);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Minhas Rotas',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.orange[900],
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            TabBar(
              controller: tabController,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Text("Não Sincronizadas")),
                Tab(icon: Text("Sincronizadas")),
              ],
              onTap: (value) {},
            ),
            Expanded(
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 16, left: 16, right: 16, top: 10),
                    child: Column(
                      children: [
                        Expanded(
                          child: rotas.isEmpty
                              ? const Center(
                                  child: Text('Nenhuma rota encontrada.'))
                              : ListView.builder(
                                  itemCount: rotas.length,
                                  itemBuilder: (context, index) {
                                    final rota = rotas[index];
                                    return Card(
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: ListTile(
                                        title: Text(
                                          "🚩 Rota ${index + 1}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.play_arrow,
                                                    size: 16,
                                                    color: Colors.green),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateConversion
                                                      .convertDateTimeFromString(
                                                          rota.dateInicial!),
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            // const SizedBox(height: 4),
                                            // Row(
                                            //   children: [
                                            //     const Icon(Icons.stop,
                                            //         size: 16,
                                            //         color: Colors.red),
                                            //     const SizedBox(width: 4),
                                            //     Text(
                                            //       DateConversion
                                            //           .convertDateTimeFromString(
                                            //               rota.dateFinal ?? ''),
                                            //       style: const TextStyle(
                                            //           fontSize: 14),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                        trailing: PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert),
                                          onSelected: (value) async {
                                            switch (value) {
                                              case 'mapa':
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        HistoricMapFlutter(
                                                            IdTrack: rota.id!),
                                                  ),
                                                );
                                                break;
                                              case 'sync':
                                                await trackViewModel
                                                    .syncRota(rota);
                                                break;
                                              case 'delete':
                                                deletarRota(rota.id!);
                                                break;
                                            }
                                          },
                                          itemBuilder: (context) {
                                            final List<PopupMenuEntry<String>>
                                                items = [
                                              const PopupMenuItem(
                                                value: 'mapa',
                                                child: ListTile(
                                                  leading: Icon(Icons.map,
                                                      color: Colors.blue),
                                                  title: Text('Ver no mapa'),
                                                ),
                                              ),
                                            ];

                                            // Só adiciona a opção de sincronizar se ainda não foi sincronizado
                                            if (rota.idSistema == null) {
                                              items.add(
                                                const PopupMenuItem(
                                                  value: 'sync',
                                                  child: ListTile(
                                                    leading: Icon(Icons.sync,
                                                        color: Colors.orange),
                                                    title: Text('Sincronizar'),
                                                  ),
                                                ),
                                              );
                                            }

                                            // Sempre mostra excluir
                                            items.add(
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: ListTile(
                                                  leading: Icon(Icons.delete,
                                                      color: Colors.red),
                                                  title: Text('Excluir'),
                                                ),
                                              ),
                                            );

                                            return items;
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Observer(
                          builder: (context) => Expanded(
                            child: trackViewModel.loading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : rotas.isEmpty
                                    ? const Center(
                                        child: Text('Nenhuma rota encontrada.'))
                                    : ListView.builder(
                                        itemCount: trackViewModel
                                            .listRotasOnline.length,
                                        itemBuilder: (context, index) {
                                          final rota = trackViewModel
                                              .listRotasOnline[index];
                                          return Card(
                                            elevation: 3,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: ListTile(
                                              title: Text(
                                                "🚩 Rota ${index + 1}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.play_arrow,
                                                          size: 16,
                                                          color: Colors.green),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        DateConversion
                                                            .convertDateTimeFromString(
                                                                rota.dateInicial!),
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ],
                                                  ),
                                                  // const SizedBox(height: 4),
                                                  // Row(
                                                  //   children: [
                                                  //     const Icon(Icons.stop,
                                                  //         size: 16,
                                                  //         color: Colors.red),
                                                  //     const SizedBox(width: 4),
                                                  //     Text(
                                                  //       DateConversion
                                                  //           .convertDateTimeFromString(
                                                  //               rota.dateFinal ?? ''),
                                                  //       style: const TextStyle(
                                                  //           fontSize: 14),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                ],
                                              ),
                                              trailing: PopupMenuButton<String>(
                                                icon:
                                                    const Icon(Icons.more_vert),
                                                onSelected: (value) async {
                                                  switch (value) {
                                                    case 'mapa':
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              HistoricMapFlutter(
                                                                  IdTrack:
                                                                      rota.id!),
                                                        ),
                                                      );
                                                      break;

                                                    case 'delete':
                                                      deletarRota(rota.id!);
                                                      break;
                                                  }
                                                },
                                                itemBuilder: (context) {
                                                  final List<
                                                      PopupMenuEntry<
                                                          String>> items = [
                                                    const PopupMenuItem(
                                                      value: 'mapa',
                                                      child: ListTile(
                                                        leading: Icon(Icons.map,
                                                            color: Colors.blue),
                                                        title:
                                                            Text('Ver no mapa'),
                                                      ),
                                                    ),
                                                  ];

                                                  // Sempre mostra excluir
                                                  items.add(
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: ListTile(
                                                        leading: Icon(
                                                            Icons.delete,
                                                            color: Colors.red),
                                                        title: Text('Excluir'),
                                                      ),
                                                    ),
                                                  );

                                                  return items;
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
