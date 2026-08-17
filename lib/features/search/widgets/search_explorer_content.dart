import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/explorer_provider.dart';
import 'search_error_state.dart';
import 'search_explorer_section.dart';

class ExplorerContent extends ConsumerWidget {
  const ExplorerContent({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final explorerAsync = ref.watch(
      explorerProvider,
    );

    return explorerAsync.when(
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },

      error: (error, stackTrace) {
        return ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(explorerProvider);
          },
        );
      },

      data: (content) {
        return ListView(
          padding: const EdgeInsets.only(
            bottom: 24,
          ),
          children: [
            if (content.recommendedMovies.isNotEmpty)
              ExplorerSection(
                title: 'Films recommandés pour vous',
                movies: content.recommendedMovies,
              ),

            if (content.recommendedTvShows.isNotEmpty)
              ExplorerSection(
                title: 'Séries recommandées pour vous',
                tvShows: content.recommendedTvShows,
              ),

            ExplorerSection(
              title: 'Films populaires',
              movies: content.popularMovies,
            ),

            ExplorerSection(
              title: 'Séries populaires',
              tvShows: content.popularTvShows,
            ),

            ExplorerSection(
              title: 'Films actuellement au cinéma',
              movies: content.nowPlayingMovies,
            ),

            ExplorerSection(
              title: 'Séries actuellement diffusées',
              tvShows: content.onTheAirTvShows,
            ),
          ],
        );
      },
    );
  }
}