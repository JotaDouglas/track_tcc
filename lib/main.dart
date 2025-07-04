import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/configs/theme_settings.dart';
import 'package:track_tcc_app/helper/supabase.helper.dart';
import 'package:track_tcc_app/routes/routes.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseLogin().supabaseUrl,
    anonKey: SupabaseLogin().supabaseKey,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<LoginViewModel>(create: (_) => LoginViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'Track TCC App',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      themeMode: themeProvider.mode,                    // ← usa o provider
      theme: ThemeData(                                 // tema claro
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(                             // tema escuro
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}
