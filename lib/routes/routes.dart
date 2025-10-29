import 'package:go_router/go_router.dart';
import 'package:track_tcc_app/views/cerca/cerca.map.view.dart';
import 'package:track_tcc_app/views/grupo/grupo_buscar.view.dart';
import 'package:track_tcc_app/views/grupo/grupo_criar.view.dart';
import 'package:track_tcc_app/views/grupo/grupo_detalhes.view.dart';
import 'package:track_tcc_app/views/grupo/grupo_home.view.dart';
import 'package:track_tcc_app/views/historicos/historico-home-detalhes.view.dart';
import 'package:track_tcc_app/views/historicos/historico-home.view.dart';
import 'package:track_tcc_app/views/home/home.view.dart';
import 'package:track_tcc_app/views/live/live_home.view.dart';
import 'package:track_tcc_app/views/live/live_location.view.dart';
import 'package:track_tcc_app/views/login/forgetKey.view.dart';
import 'package:track_tcc_app/views/login/login.view.dart';
import 'package:track_tcc_app/views/login/signup.view.dart';
import 'package:track_tcc_app/views/login/userDates.view.dart';
import 'package:track_tcc_app/views/splash.view.dart';
import 'package:track_tcc_app/views/settings.view.dart';
import 'package:track_tcc_app/views/track/tracking.view.dart';
import 'package:track_tcc_app/views/user/edit_perfil.view.dart';
import 'package:track_tcc_app/views/user/friends.view.dart';
import 'package:track_tcc_app/views/user/perfil.view.dart';
import 'package:track_tcc_app/views/user/search_users.view.dart';
import 'package:track_tcc_app/views/user/solicitacoes.view.dart';

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
          path: "/historico-home",
          name: 'historico-home',
          builder: (context, status) => const RotasPage()),
      GoRoute(
          path: "/historico-detalhes",
          name: 'historico-detalhes',
          builder: (context, status) => const RotaDetalhePage(
                rotaId: null,
              )),
      GoRoute(
          path: "/user-perfil",
          name: 'user-perfil',
          builder: (context, status) => const PerfilView()),
      GoRoute(
          path: "/user-perfil-edit",
          name: 'user-perfil-edit',
          builder: (context, status) => const EditarPerfilView()),
      GoRoute(
          path: "/user-friends",
          name: 'user-friends',
          builder: (context, status) => const FriendsView()),
      GoRoute(
          path: "/user-friends-requests",
          name: 'user-friends-requests',
          builder: (context, status) => const FriendRequestsView()),
      GoRoute(
          path: "/user-search",
          name: 'user-search',
          builder: (context, status) => const BuscarAmigosView()),
      GoRoute(
          path: "/location-share-home",
          name: 'location-share-home',
          builder: (context, status) => const LocalizacoesPage()),
      GoRoute(
          path: "/cerca-map",
          name: 'cerca-map',
          builder: (context, status) => const CercaMapView()),
      GoRoute(
        path: "/grupos",
        name: 'grupos',
        builder: (context, state) => const GroupListScreen(),
      ),
      GoRoute(
        path: "/grupo-entrar",
        name: 'grupo-entrar',
        builder: (context, state) => const JoinGroupScreen(),
      ),
      GoRoute(
        path: "/grupo-criar",
        name: 'grupo-criar',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        path: "/grupo-detalhe",
        name: 'grupo-detalhe',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return GroupDetailScreen(
            grupoId: data['id'],
            nomeGrupo: data['nome'],
            codigo: data['codigo'],
          );
        },
      ),
      GoRoute(
        path: "/location-share-map/:userId",
        name: 'location-share-map',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return LiveTrackingPage(userId: userId);
        },
      ),
      GoRoute(
          path: "/settings-theme",
          name: 'settings-theme',
          builder: (context, status) => const SettingsPage()),
    ],
  );
  static GoRouter get router => _router;
}
