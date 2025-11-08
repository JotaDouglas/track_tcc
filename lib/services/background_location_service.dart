import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BackgroundLocationService {
  static const String _notificationChannelId = 'location_service_channel';
  static const String _notificationChannelName = 'Serviço de Localização';
  static const int _notificationId = 888;

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Configurar notificações para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Este canal é usado para notificações de rastreamento de localização',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Rastreamento de Localização',
        initialNotificationContent: 'Rastreando sua localização...',
        foregroundServiceNotificationId: _notificationId,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Inicializar Supabase
    try {
      final prefs = await SharedPreferences.getInstance();
      final supabaseUrl = prefs.getString('supabase_url');
      final supabaseKey = prefs.getString('supabase_key');

      if (supabaseUrl != null && supabaseKey != null) {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseKey,
        );
      }
    } catch (e) {
      log('Erro ao inicializar Supabase no background: $e');
    }

    // Timer para rastrear localização
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          try {
            final prefs = await SharedPreferences.getInstance();
            final isTracking = prefs.getBool('is_tracking') ?? false;
            final trackingInterval = prefs.getInt('tracking_interval') ?? 30;

            if (!isTracking) {
              timer.cancel();
              service.stopSelf();
              return;
            }

            // Obter localização atual
            final position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10,
              ),
            );

            // Obter dados do usuário
            final userId = prefs.getString('user_id');
            final userName = prefs.getString('user_name') ?? 'Usuário';

            if (userId != null) {
              // Enviar para Supabase
              try {
                final supabase = Supabase.instance.client;
                final row = {
                  'user_id': userId,
                  'data_hora': DateTime.now().toIso8601String(),
                  'latitude': position.latitude,
                  'longitude': position.longitude,
                  'user_name': userName,
                };

                await supabase.from('localizacoes').upsert(row, onConflict: 'user_id');

                log('Localização enviada em background: ${position.latitude}, ${position.longitude}');

                // Atualizar notificação
                service.setForegroundNotificationInfo(
                  title: 'Rastreamento Ativo',
                  content: 'Última atualização: ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                );
              } catch (e) {
                log('Erro ao enviar localização para Supabase: $e');
              }
            }

            // Enviar evento com a localização
            service.invoke(
              'update',
              {
                'latitude': position.latitude,
                'longitude': position.longitude,
                'timestamp': DateTime.now().toIso8601String(),
              },
            );

            // Ajustar o timer de acordo com o intervalo configurado
            if (trackingInterval != 30) {
              timer.cancel();
              Timer.periodic(Duration(seconds: trackingInterval), (newTimer) async {
                final stillTracking = prefs.getBool('is_tracking') ?? false;
                if (!stillTracking) {
                  newTimer.cancel();
                  service.stopSelf();
                }
              });
            }
          } catch (e) {
            log('Erro no rastreamento em background: $e');
          }
        }
      }
    });
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();

    // Salvar estado de rastreamento
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_tracking', true);

    var isRunning = await service.isRunning();
    if (!isRunning) {
      service.startService();
    }
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();

    // Salvar estado de rastreamento
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_tracking', false);

    service.invoke('stopService');
  }

  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}
