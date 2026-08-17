import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/media_details_provider.dart';
import '../widgets/movie_details_content.dart';

class MovieDetailsPage extends ConsumerWidget {
  const MovieDetailsPage({
    super.key,
    required this.movieId,
  });

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieAsync = ref.watch(
      movieDetailsProvider(movieId),
    );

    return Scaffold(
      body: movieAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Impossible de charger le film.\n$error',
              textAlign: TextAlign.center,
            ),
          );
        },
        data: (movie) {
          return MovieDetailsContent(
            movie: movie,
          );
        },
      ),
    );
  }
}