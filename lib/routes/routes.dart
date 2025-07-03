import 'package:go_router/go_router.dart';
import 'package:track_tcc_app/views/historicos/historico-home-detalhes.view.dart';
import 'package:track_tcc_app/views/historicos/historico-home.view.dart';
import 'package:track_tcc_app/views/home/home.view.dart';
import 'package:track_tcc_app/views/live_locations/live_home.view.dart';
import 'package:track_tcc_app/views/live_locations/live_location.view.dart';
import 'package:track_tcc_app/views/login/forgetKey.view.dart';
import 'package:track_tcc_app/views/login/login.view.dart';
import 'package:track_tcc_app/views/login/signup.view.dart';
import 'package:track_tcc_app/views/login/userDates.view.dart';
import 'package:track_tcc_app/views/splash.view.dart';
import 'package:track_tcc_app/views/track/historico/historico.view.dart';
import 'package:track_tcc_app/views/track/tracking.view.dart';
import 'package:track_tcc_app/views/user/edit_perfil.view.dart';
import 'package:track_tcc_app/views/user/perfil.view.dart';
import 'package:track_tcc_app/views/user/search_users.view.dart';

class AppRouter {
  static final _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
          path: "/",
          name: 'splash',
          builder: (context, status) => const SplashScreen()),
      GoRoute(
          path: "/login",
          name: 'login',
          builder: (context, status) => const LoginView()),
      GoRoute(
          path: "/login/register",
          name: 'register',
          builder: (context, status) => const CadastroView()),
      GoRoute(
          path: "/login/register/name",
          name: 'registerName',
          builder: (context, status) => const UserCadastroView()),
      GoRoute(
          path: "/home",
          name: 'home',
          builder: (context, status) => const HomeView()),
      GoRoute(
          path: "/login/forgot",
          name: 'forgot',
          builder: (context, status) => const RecuperacaoSenhaView()),
      GoRoute(
          path: "/track",
          name: 'track',
          builder: (context, status) => const TrackPage()),
      GoRoute(
          path: "/historic",
          name: 'historic',
          builder: (context, status) => const HistoricoView()),
      GoRoute(
          path: "/historico-home",
          name: 'historico-home',
          builder: (context, status) => const RotasPage()),
      GoRoute(
          path: "/historico-detalhes",
          name: 'historico-detalhes',
          builder: (context, status) => const RotaDetalhePage(rotaId: null,)),
      GoRoute(
          path: "/user-perfil",
          name: 'user-perfil',
          builder: (context, status) => const PerfilView()),
      GoRoute(
          path: "/user-perfil-edit",
          name: 'user-perfil-edit',
          builder: (context, status) => const EditarPerfilView()),
      GoRoute(
          path: "/user-search",
          name: 'user-search',
          builder: (context, status) => const BuscarAmigosView()),
      GoRoute(
          path: "/location-share-home",
          name: 'location-share-home',
          builder: (context, status) => const LocalizacoesPage()),
      GoRoute(
          path: "/location-share-map",
          name: 'location-share-map',
          builder: (context, status) => const LiveTrackingPage()),
    ],
  );
  static GoRouter get router => _router;
}
