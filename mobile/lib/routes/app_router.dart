import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/games/data/game_definition.dart';
import '../features/games/presentation/game_details_screen.dart';
import '../features/games/presentation/games_screen.dart';
import '../features/games/presentation/memory_match_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/memories/data/memory_entry.dart';
import '../features/memories/presentation/memories_screen.dart';
import '../features/memories/presentation/memory_details_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/progress/presentation/progress_screen.dart';

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
      GoRoute(
        path: '/games/play/memory-match',
        builder: (context, state) =>
            MemoryMatchScreen(game: state.extra as GameDefinition?),
      ),
      GoRoute(
        path: '/progress',
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/memories',
        builder: (context, state) => const MemoriesScreen(),
      ),
      GoRoute(
        path: '/memories/details',
        builder: (context, state) =>
            MemoryDetailsScreen(memory: state.extra as MemoryEntry?),
      ),
    ],
  );
}
