
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