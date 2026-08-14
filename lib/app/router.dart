import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/pages/login_page.dart';
import '../features/authentication/pages/register_page.dart';
import '../../../core/supabase/supabase_provider.dart';
import '../features/home/home_page.dart';
import '../features/search/search_page.dart';
import '../features/library/library_page.dart';
import '../features/profile/profile_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = AuthRouterNotifier(ref);

  ref.onDispose(routerNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: routerNotifier,

    redirect: (context, state) {
      final session = routerNotifier.session;

      final isLoggedIn = session != null;

      final isLoggingIn =
          state.matchedLocation == '/login';

      final isRegistering =
          state.matchedLocation == '/register';

      final isAuthPage =
          isLoggingIn || isRegistering;

      if (!isLoggedIn && !isAuthPage) {
        return '/login';
      }

      if (isLoggedIn && isAuthPage) {
        return '/';
      }

      return null;
    },

    routes: [

      // AUTHENTIFICATION
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterPage();
        },
      ),

      // APPLICATION
      StatefulShellRoute.indexedStack(
        builder: (
          context,
          state,
          navigationShell,
        ) {
          return MainScaffold(
            navigationShell: navigationShell,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  return const HomePage();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) {
                  return const SearchPage();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) {
                  return const LibraryPage();
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return const ProfilePage();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class AuthRouterNotifier
    extends ChangeNotifier {
  AuthRouterNotifier(this.ref) {
    _subscription = ref
        .read(supabaseProvider)
        .auth
        .onAuthStateChange
        .listen((authState) {
      session = authState.session;
      notifyListeners();
    });

    session = ref
        .read(supabaseProvider)
        .auth
        .currentSession;
  }

  final Ref ref;

  late final StreamSubscription<AuthState>
      _subscription;

  Session? session;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(
    int index,
  ) {
    navigationShell.goBranch(
      index,
      initialLocation:
          index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,

      bottomNavigationBar: NavigationBar(
        selectedIndex:
            navigationShell.currentIndex,

        onDestinationSelected:
            _onDestinationSelected,

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Explorer',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.video_library_outlined,
            ),
            selectedIcon: Icon(
              Icons.video_library,
            ),
            label: 'Bibliothèque',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}