// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_tcc_app/configs/theme_settings.dart';
import 'package:track_tcc_app/routes/routes.dart';
import 'package:track_tcc_app/services/background_location_service.dart';
import 'package:track_tcc_app/viewmodel/amizade.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/cerca.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/grupo/grupo.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/login.viewmodel.dart';
import 'package:track_tcc_app/viewmodel/tracking.viewmodel.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  // Salvar credenciais do Supabase para uso no background service
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('supabase_url', dotenv.env['SUPABASE_URL']!);
  await prefs.setString('supabase_key', dotenv.env['SUPABASE_KEY']!);

  // Inicializar serviço de background
  await BackgroundLocationService.initializeService();

  // Inicializa e carrega o ThemeProvider antes do runApp
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  // Inicializa o OneSignal App ID
  OneSignal.initialize(dotenv.env['MESSAGE_KEY']!);

  OneSignal.Notifications.requestPermission(false);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        Provider<LoginViewModel>(create: (_) => LoginViewModel()),
        Provider<AmizadeViewModel>(create: (_) => AmizadeViewModel()),
        Provider<CercaViewModel>(create: (_) => CercaViewModel()),
        Provider<TrackingViewModel>(create: (_) => TrackingViewModel()),
        Provider<GrupoViewModel>(
            create: (_) => GrupoViewModel(LoginViewModel())),
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
      themeMode: themeProvider.mode, // usa o provider
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          hintStyle: TextStyle(color: Colors.grey[800]),
          prefixIconColor: Colors.grey[800],
          suffixIconColor: Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[800]!, width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: TextStyle(color: Colors.deepOrange[100]),
          prefixIconColor: Colors.deepOrange[100],
          suffixIconColor: Colors.deepOrange[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.deepOrange[100]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.deepOrange[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.deepOrange[100]!, width: 2),
          ),
        ),
      ),
    );
  }
}
