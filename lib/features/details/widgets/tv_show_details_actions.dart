import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../series/models/tv_show.dart';
import '../../library/providers/library_provider.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import '../../library/providers/library_repository_provider.dart';

class TvShowDetailsActions extends ConsumerWidget {
  const TvShowDetailsActions({
    super.key,
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final libraryAsync = ref.watch(
      librarySeriesProvider,
    );

    final watchedEpisodes = ref.watch(
      watchProgressProvider.select(
        (state) => state.episodes.values
            .where(
              (episode) => episode.tvShowId == tvShow.id,
            )
            .length,
      ),
    );

    final totalEpisodes =
        tvShow.numberOfEpisodes ?? 0;

    final isWatched =
        totalEpisodes > 0 &&
        watchedEpisodes >= totalEpisodes;

    final isFollowed = libraryAsync.maybeWhen(
      data: (series) {
        return series.any(
          (item) => item['tmdb_id'] == tvShow.id,
        );
      },
      orElse: () => false,
    );

    final isLoading = libraryAsync.isLoading;

    return Row(
      children: [
        Expanded(
          child: isWatched
              ? OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          ref
                              .read(
                                watchProgressProvider
                                    .notifier,
                              )
                              .toggleTvShowWatched(
                                tvShowId: tvShow.id,
                                tvShowName: tvShow.name,
                                posterPath:
                                    tvShow.posterPath,
                              );
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Vu'),
                )
              : FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          ref
                              .read(
                                watchProgressProvider
                                    .notifier,
                              )
                              .toggleTvShowWatched(
                                tvShowId: tvShow.id,
                                tvShowName: tvShow.name,
                                posterPath:
                                    tvShow.posterPath,
                              );
                        },
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Marquer comme vu',
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () async {
                    try {
                      final repository = ref.read(
                        libraryRepositoryProvider,
                      );

                      if (isFollowed) {
                        await repository.removeSeries(
                          tmdbId: tvShow.id,
                        );
                      } else {
                        await repository.addSeries(
                          tmdbId: tvShow.id,
                          name: tvShow.name,
                          posterPath:
                              tvShow.posterPath,
                        );
                      }

                      ref.invalidate(
                        librarySeriesProvider,
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Impossible de modifier la bibliothèque : $error',
                          ),
                        )
                      );
                    }
                  },
            icon: Icon(
              isFollowed
                  ? Icons.bookmark
                  : Icons.add,
            ),
            label: Text(
              isFollowed
                  ? 'Dans ma bibliothèque'
                  : 'À voir',
            ),
          ),
        ),
      ],
    );
  }
}