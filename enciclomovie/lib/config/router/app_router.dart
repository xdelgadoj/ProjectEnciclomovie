/*
import 'package:enciclomovie/presentation/views/movies/notifications_view.dart';
import 'package:go_router/go_router.dart';
import 'package:enciclomovie/presentation/screens/screens.dart';

final appRouter = GoRouter(
  initialLocation: '/home/0',
  routes: [
    
    GoRoute(
      path: '/home/:page',
      name: HomeScreen.name,
      builder: (context, state) {
        final pageIndex = int.parse( state.pathParameters['page'] ?? '0' );

        return HomeScreen( pageIndex: pageIndex );
      },
      routes: [
         GoRoute(
          path: '/movie/:id',
          name: MovieScreen.name,
          builder: (context, state) {
            final movieId = state.pathParameters['id'] ?? 'no-id';

            return MovieScreen( movieId: movieId );
          },
        ),
      ]
    ),

    GoRoute(
      path: '/push-details/:messageId',
      name: DetailsScreen.name,
      builder: (context, state) {
        final messageId = state.pathParameters['messageId'] ?? '';
        return DetailsScreen(pushMessageId: messageId);
      },
    ),

    GoRoute(
      path: '/notifications',
      name: NotificationsView.name,
      builder: (context, state) => const NotificationsView(),
    ),

    GoRoute(
      path: '/',
      redirect: ( _ , __ ) => '/home/0',
    ),

  ]
);
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:enciclomovie/presentation/views/views.dart';
import 'package:enciclomovie/presentation/screens/screens.dart';
import 'package:enciclomovie/presentation/providers/auth/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authValue = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      final onSplash = state.matchedLocation == '/splash';

      return authValue.when(
        data: (isAuthenticated) {
          if (onSplash) {
            return isAuthenticated ? '/home/0' : '/login';
          }
          if (!isAuthenticated && !loggingIn) return '/login';
          if (isAuthenticated && loggingIn) return '/home/0';
          return null;
        },
        loading: () => null,
        error: (_, __) => '/login',
      );
    },

    routes: [
      GoRoute(
        path: '/splash',
        name: SplashScreen.name,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: LoginScreen.name,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RegisterScreen.name,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home/:page',
        name: HomeScreen.name,
        builder: (context, state) {
          final pageIndex = int.tryParse(state.pathParameters['page'] ?? '0') ?? 0;
          return HomeScreen(pageIndex: pageIndex);
        },
        routes: [
          GoRoute(
            path: 'movie/:id',
            name: MovieScreen.name,
            builder: (context, state) {
              final movieId = state.pathParameters['id'] ?? 'no-id';
              return MovieScreen(movieId: movieId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/push-details/:messageId',
        name: DetailsScreen.name,
        builder: (context, state) {
          final messageId = state.pathParameters['messageId'] ?? '';
          return DetailsScreen(pushMessageId: messageId);
        },
      ),
      GoRoute(
        path: '/notifications',
        name: NotificationsView.name,
        builder: (_, __) => const NotificationsView(),
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home/0',
      ),
    ],
  );
});