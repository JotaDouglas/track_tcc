import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_tcc_app/configs/theme_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    final isDark = provider.mode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListTile(
        title: const Text('Modo Escuro'),
        trailing: Switch(
          value: isDark,
          onChanged: (v) => provider.toggleTheme(v),
        ),
      ),
    );
  }
}
