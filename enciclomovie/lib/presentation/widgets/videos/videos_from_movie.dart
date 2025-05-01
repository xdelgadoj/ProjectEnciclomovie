import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enciclomovie/presentation/providers/providers.dart';
import 'package:enciclomovie/domain/entities/entities.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final FutureProviderFamily<List<Video>, int> videosFromMovieProvider = FutureProvider.family((ref, int movieId) {
  final movieRepository = ref.watch(movieRepositoryProvider);
  return movieRepository.getYoutubeVideosById(movieId);
});

class VideosFromMovie extends ConsumerWidget {

  final int movieId;

  const VideosFromMovie({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref ) {
    final moviesFromVideo = ref.watch(videosFromMovieProvider(movieId));

    return moviesFromVideo.when(
      data: ( videos ) => _VideosList( videos: videos ),
      error: (_ , __) => const Center(child: Text('No se pudo cargar películas similares') ), 
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _VideosList extends StatelessWidget {

  final List<Video> videos;

  const _VideosList({required this.videos });

  @override
  Widget build(BuildContext context) {

    //* Nada que mostrar
    if ( videos.isEmpty ) {
      return const SizedBox(); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Divider(thickness: 1.5),
        ),
        const SizedBox(height: 10),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, size: 24, color: Colors.redAccent),
              const SizedBox(width: 8),
              const Text(
                'Video',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Reproductor de YouTube
        _YouTubeVideoPlayer(
          youtubeId: videos.first.youtubeKey,
          name: videos.first.name,
        ),

        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Divider(thickness: 1.5),
        ),
      ],
    );
  }
}

class _YouTubeVideoPlayer extends StatefulWidget {

  final String youtubeId;
  final String name;

  const _YouTubeVideoPlayer({ required this.youtubeId, required this.name });

  @override
  State<_YouTubeVideoPlayer> createState() => _YouTubeVideoPlayerState();
}

class _YouTubeVideoPlayerState extends State<_YouTubeVideoPlayer> {

  late YoutubePlayerController _controller;  

  @override
  void initState() {
    super.initState();
    
    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      flags: const YoutubePlayerFlags(
        hideThumbnail: true,
        showLiveFullscreenButton: false,
        mute: false,
        autoPlay: false,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name),
          YoutubePlayer(controller: _controller)
        ],
      )
    );
  }
}