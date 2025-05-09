import 'package:go_router/go_router.dart';
import 'package:track_tcc_app/views/historicos/historico-home-detalhes.view.dart';
import 'package:track_tcc_app/views/historicos/historico-home.view.dart';
import 'package:track_tcc_app/views/home/home.view.dart';
import 'package:track_tcc_app/views/login/forgetKey.view.dart';
import 'package:track_tcc_app/views/login/login.view.dart';
import 'package:track_tcc_app/views/login/signup.view.dart';
import 'package:track_tcc_app/views/login/userDates.view.dart';
import 'package:track_tcc_app/views/splash.view.dart';
import 'package:track_tcc_app/views/track/historico/historico.view.dart';
import 'package:track_tcc_app/views/track/tracking.view.dart';

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
    ],
  );
  static GoRouter get router => _router;
}
