import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:track_tcc_app/viewmodel/cerca.viewmodel.dart';

class CercaMapView extends StatefulWidget {
  const CercaMapView({super.key});

  @override
  State<CercaMapView> createState() => _CercaMapViewState();
}

class _CercaMapViewState extends State<CercaMapView> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  final _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<CercaViewModel>(context, listen: false);
    vm.listarCercas();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentLocation = LatLng(pos.latitude, pos.longitude));
      _mapController.move(_currentLocation!, 16);
    } catch (e) {
      // Localização padrão se falhar
      setState(() => _currentLocation = LatLng(-23.55, -46.63));
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CercaViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) => Text(
            vm.cercaAtual ?? "Gerenciar Cercas",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[900],
        foregroundColor: Colors.white,
        actions: [
          // Botão de ajuda
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _mostrarAjuda(context, vm),
          ),
        ],
      ),
      body: Stack(
        children: [
          Observer(
            builder: (_) => FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? LatLng(-23.55, -46.63),
                initialZoom: 14,
                onTap: (tapPos, latlng) {
                  if (vm.modo == 'editar' || vm.modo == 'criar') {
                    vm.adicionarPonto(latlng);
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Ponto ${vm.pontos.length} adicionado"),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                // Polígonos das cercas
                ..._buildPolygons(vm),
                // Marcadores (pins)
                MarkerLayer(markers: _buildMarkers(vm)),
                // Marcador de localização atual
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Indicador de modo aprimorado
          Positioned(
            top: 10,
            right: 10,
            child: Observer(
              builder: (_) => Card(
                elevation: 4,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getModoIcon(vm.modo),
                        color: _getModoColor(vm.modo),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getModoTexto(vm.modo),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getModoColor(vm.modo),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Barra de ações rápidas na parte inferior
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Observer(
              builder: (_) => _buildActionBar(vm),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _mostrarMenu(context, vm),
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.menu),
          ),
          SizedBox(height: 200,)
        ],
      ),
    );
  }

  Widget _buildActionBar(CercaViewModel vm) {
    if (vm.modo == 'visualizar') {
      return Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.add,
                label: 'Nova',
                color: Colors.green,
                onTap: () => _criarNovaCerca(vm),
              ),
              _buildActionButton(
                icon: Icons.list,
                label: 'Listar',
                color: Colors.blue,
                onTap: () => _mostrarLista(vm),
              ),
              _buildActionButton(
                icon: Icons.layers,
                label: 'Ver Todas',
                color: Colors.orange,
                onTap: () => _visualizarTodas(vm),
              ),
            ],
          ),
        ),
      );
    } else if (vm.modo == 'criar' || vm.modo == 'editar') {
      return Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.undo,
                label: 'Desfazer',
                color: Colors.grey,
                onTap: vm.pontos.isNotEmpty
                    ? () {
                        final totalAntes = vm.pontos.length;
                        vm.removerPonto(vm.pontos.length - 1);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Ponto $totalAntes removido. Total: ${vm.pontos.length} pontos"),
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                      }
                    : null,
              ),
              _buildActionButton(
                icon: Icons.save,
                label: 'Salvar',
                color: Colors.green,
                onTap: vm.pontos.length >= 3 ? () => _salvarCerca(vm) : null,
              ),
              _buildActionButton(
                icon: Icons.cancel,
                label: 'Cancelar',
                color: Colors.red,
                onTap: () => _cancelarEdicao(vm),
              ),
            ],
          ),
        ),
      );
    } else if (vm.modo == 'visualizar_todas') {
      return Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.close,
                label: 'Fechar Visualização',
                color: Colors.grey,
                onTap: () {
                  vm.modo = 'visualizar';
                  vm.cercasMap.clear();
                },
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isEnabled
                  ? color.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEnabled ? color : Colors.grey,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? color : Colors.grey,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? color : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(CercaViewModel vm) {
    final List<Marker> markers = [];

    // Visualizando todas as cercas
    if (vm.modo == 'visualizar_todas' && vm.cercasMap.isNotEmpty) {
      vm.cercasMap.forEach((nome, pontos) {
        for (var i = 0; i < pontos.length; i++) {
          markers.add(
            Marker(
              point: pontos[i],
              width: 35,
              height: 35,
              child: Icon(
                Icons.location_on,
                color: Colors.primaries[
                    vm.cercasMap.keys.toList().indexOf(nome) %
                        Colors.primaries.length],
                size: 30,
              ),
            ),
          );
        }
      });
      return markers;
    }

    // Modo criar ou editar - marcadores interativos
    for (var i = 0; i < vm.pontos.length; i++) {
      markers.add(
        Marker(
          point: vm.pontos[i],
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: (vm.modo == 'editar' || vm.modo == 'criar')
                ? () => _confirmarRemocaoPonto(vm, i)
                : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: vm.modo == 'editar' ? Colors.red : Colors.blue,
                  size: 40,
                ),
                Positioned(
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<PolygonLayer> _buildPolygons(CercaViewModel vm) {
    final List<PolygonLayer> layers = [];

    // Visualizando todas as cercas
    if (vm.modo == 'visualizar_todas' && vm.cercasMap.isNotEmpty) {
      for (var entry in vm.cercasMap.entries) {
        final nome = entry.key;
        final pontos = entry.value;

        if (pontos.length >= 3) {
          layers.add(
            PolygonLayer(
              polygons: [
                Polygon(
                  points: [...pontos, pontos.first],
                  color: Colors.primaries[
                          vm.cercasMap.keys.toList().indexOf(nome) %
                              Colors.primaries.length]
                      .withOpacity(0.25),
                  borderColor: Colors.primaries[
                      vm.cercasMap.keys.toList().indexOf(nome) %
                          Colors.primaries.length],
                  borderStrokeWidth: 3,
                  isFilled: true,
                ),
              ],
            ),
          );
        }
      }
    }
    // Visualizando/editando cerca específica
    else if (vm.pontos.length >= 3) {
      layers.add(
        PolygonLayer(
          polygons: [
            Polygon(
              points: [...vm.pontos, vm.pontos.first],
              color: Colors.blue.withOpacity(0.25),
              borderColor: Colors.blue,
              borderStrokeWidth: 3,
              isFilled: true,
            ),
          ],
        ),
      );
    }

    return layers;
  }

  void _confirmarRemocaoPonto(CercaViewModel vm, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remover Ponto"),
        content: Text("Deseja remover o ponto ${index + 1}?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Remover"),
            onPressed: () {
              vm.removerPonto(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Ponto ${index + 1} removido. Total: ${vm.pontos.length} pontos"),
                  duration: const Duration(milliseconds: 1500),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _criarNovaCerca(CercaViewModel vm) {
    _nomeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova Cerca"),
        content: TextField(
          controller: _nomeController,
          decoration: const InputDecoration(
            labelText: "Nome da cerca",
            hintText: "Ex: Área Restrita",
            prefixIcon: Icon(Icons.edit),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Criar"),
            onPressed: () {
              if (_nomeController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Digite um nome para a cerca")),
                );
                return;
              }
              vm.iniciarNovaCerca();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Toque no mapa para adicionar pontos (mínimo 3)"),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _salvarCerca(CercaViewModel vm) {
    if (_nomeController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Nome Necessário"),
          content: TextField(
            controller: _nomeController,
            decoration: const InputDecoration(
              labelText: "Nome da cerca",
              prefixIcon: Icon(Icons.edit),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Salvar"),
              onPressed: () {
                if (_nomeController.text.trim().isNotEmpty) {
                  vm.salvarCerca(_nomeController.text.trim());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cerca salva com sucesso!")),
                  );
                }
              },
            ),
          ],
        ),
      );
    } else {
      vm.salvarCerca(_nomeController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cerca salva com sucesso!")),
      );
    }
  }

  void _cancelarEdicao(CercaViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancelar"),
        content: const Text(
            "Deseja cancelar a edição? As alterações não salvas serão perdidas."),
        actions: [
          TextButton(
            child: const Text("Não"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Sim"),
            onPressed: () {
              vm.modo = 'visualizar';
              vm.pontos.clear();
              vm.cercaAtual = null;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _mostrarLista(CercaViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Minhas Cercas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: vm.cercasSalvas.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            "Nenhuma cerca cadastrada",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: vm.cercasSalvas.length,
                      itemBuilder: (context, index) {
                        final nome = vm.cercasSalvas[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                nome[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _editarCerca(vm, nome);
                                    Navigator.pop(context);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _confirmarExclusao(context, vm, nome),
                                ),
                              ],
                            ),
                            onTap: () {
                              _editarCerca(vm, nome);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _editarCerca(CercaViewModel vm, String nome) {
    vm.carregarCerca(nome);
    _nomeController.text = nome;
    vm.modo = 'editar'; // Força o modo de edição
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            "Modo de edição ativado. Toque no mapa para adicionar pontos ou nos pins para remover."),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _confirmarExclusao(
      BuildContext context, CercaViewModel vm, String nome) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Excluir Cerca"),
        content: Text("Deseja realmente excluir a cerca '$nome'?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Excluir"),
            onPressed: () {
              vm.deletarCerca(nome);
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Fecha o bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Cerca '$nome' excluída com sucesso")),
              );
            },
          ),
        ],
      ),
    );
  }

  void _visualizarTodas(CercaViewModel vm) async {
    await vm.mostrarTodasCercas();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Visualizando todas as cercas"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _mostrarMenu(BuildContext context, CercaViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Menu de Opções",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text("Criar Nova Cerca"),
              onTap: () {
                Navigator.pop(context);
                _criarNovaCerca(vm);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.blue),
              title: const Text("Ver Minhas Cercas"),
              onTap: () {
                Navigator.pop(context);
                _mostrarLista(vm);
              },
            ),
            ListTile(
              leading: const Icon(Icons.layers, color: Colors.orange),
              title: const Text("Visualizar Todas"),
              onTap: () {
                Navigator.pop(context);
                _visualizarTodas(vm);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.purple),
              title: const Text("Ajuda"),
              onTap: () {
                Navigator.pop(context);
                _mostrarAjuda(context, vm);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAjuda(BuildContext context, CercaViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Como Usar"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAjudaItem(
                Icons.add_circle,
                "Criar Cerca",
                "Toque em 'Nova' e depois toque no mapa para adicionar pontos (mínimo 3).",
              ),
              _buildAjudaItem(
                Icons.edit,
                "Editar Cerca",
                "Selecione uma cerca na lista e toque nos pontos para removê-los.",
              ),
              _buildAjudaItem(
                Icons.delete,
                "Excluir Cerca",
                "Na lista de cercas, toque no ícone de lixeira ao lado da cerca.",
              ),
              _buildAjudaItem(
                Icons.layers,
                "Visualizar Todas",
                "Veja todas as suas cercas no mapa simultaneamente.",
              ),
              _buildAjudaItem(
                Icons.undo,
                "Desfazer",
                "Remove o último ponto adicionado durante a criação/edição.",
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text("Entendi"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAjudaItem(IconData icon, String titulo, String descricao) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModoIcon(String modo) {
    return switch (modo) {
      'criar' => Icons.add_location,
      'editar' => Icons.edit_location,
      'visualizar_todas' => Icons.layers,
      _ => Icons.visibility,
    };
  }

  Color _getModoColor(String modo) {
    return switch (modo) {
      'criar' => Colors.green,
      'editar' => Colors.orange,
      'visualizar_todas' => Colors.purple,
      _ => Colors.blue,
    };
  }

  String _getModoTexto(String modo) {
    return switch (modo) {
      'criar' => 'Criando',
      'editar' => 'Editando',
      'visualizar_todas' => 'Ver Todas',
      _ => 'Visualizar',
    };
  }
}
