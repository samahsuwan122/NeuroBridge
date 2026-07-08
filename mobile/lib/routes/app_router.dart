import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/games/data/game_definition.dart';
import '../features/games/presentation/game_details_screen.dart';
import '../features/games/presentation/games_screen.dart';
import '../features/home/presentation/home_screen.dart';

/// Builds the app router. It refreshes when auth state changes and redirects
/// unauthenticated users to /login.
GoRouter createRouter(AuthController auth) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final atLogin = state.matchedLocation == '/login';
      if (!loggedIn) return atLogin ? null : '/login';
      if (atLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/games',
        builder: (context, state) => const GamesScreen(),
      ),
      GoRoute(
        path: '/games/details',
        builder: (context, state) =>
            GameDetailsScreen(game: state.extra as GameDefinition?),
      ),
    ],
  );
}
