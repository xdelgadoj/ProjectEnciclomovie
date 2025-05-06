import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:enciclomovie/domain/entities/movie.dart';
import 'package:enciclomovie/presentation/delegates/search_movie_delegate.dart';
import 'package:enciclomovie/presentation/providers/providers.dart';
 
class CustomAppbar extends ConsumerWidget {
  final VoidCallback onNotificationsTap;

  const CustomAppbar({super.key, required this.onNotificationsTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final notificationCount = ref.watch(notificationCountProvider);

    return Row(
      children: [
        Icon(Icons.movie_outlined, color: colors.primary),
        const SizedBox(width: 5),
        Text('Enciclomovie', style: titleStyle),
        const Spacer(),

        // Search icon
        IconButton(
          onPressed: () {
            final searchedMovies = ref.read(searchedMoviesProvider);
            final searchQuery = ref.read(searchQueryProvider);

            showSearch<Movie?>(
              context: context,
              query: searchQuery,
              delegate: SearchMovieDelegate(
                initialMovies: searchedMovies,
                searchMovies: ref.read(searchedMoviesProvider.notifier).searchMoviesByQuery,
              ),
            ).then((movie) {
              if (movie == null) return;
              context.push('/home/0/movie/${movie.id}');
            });
          },
          icon: const Icon(Icons.search),
        ),

        // Notification icon with animated badge
        IconButton(
          onPressed: onNotificationsTap,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none),
              Positioned(
                right: -2,
                top: -2,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: notificationCount > 0
                      ? Container(
                          key: ValueKey(notificationCount),
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            notificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey(0)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}