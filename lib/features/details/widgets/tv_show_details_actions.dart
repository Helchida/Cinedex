import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../series/models/tv_show.dart';
import '../../library/providers/library_provider.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import '../../library/providers/library_repository_provider.dart';
import '../providers/media_details_provider.dart';
import '../../library/providers/next_episode_provider.dart';

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

    final isFollowed = libraryAsync.maybeWhen(
      data: (series) {
        return series.any(
          (item) => item['tmdb_id'] == tvShow.id,
        );
      },
      orElse: () => false,
    );

    final isLoading = libraryAsync.isLoading;

    final watchStatusAsync = ref.watch(
      tvShowWatchStatusProvider(tvShow.id),
    );

    final isWatched =
        watchStatusAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );

    return Column(
      children: [
        Row(
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
                                    tvShowName:
                                        tvShow.name,
                                    posterPath:
                                        tvShow.posterPath,
                                  );

                              ref.invalidate(
                                tvShowWatchStatusProvider(
                                  tvShow.id,
                                ),
                              );

                              ref.invalidate(
                                tvShowAllEpisodesWatchedProvider(
                                  tvShow.id,
                                ),
                              );
                            },
                      icon: const Icon(
                        Icons.check,
                      ),
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
                                    tvShowName:
                                        tvShow.name,
                                    posterPath:
                                        tvShow.posterPath,
                                  );

                              ref.invalidate(
                                tvShowWatchStatusProvider(
                                  tvShow.id,
                                ),
                              );

                              ref.invalidate(
                                tvShowAllEpisodesWatchedProvider(
                                  tvShow.id,
                                ),
                              );
                            },
                      icon: const Icon(
                        Icons.check,
                      ),
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
                          final repository =
                              ref.read(
                            libraryRepositoryProvider,
                          );

                          if (isFollowed) {
                            await repository
                                .removeSeries(
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

                          ref.invalidate(
                            tvShowStartSeasonProvider(
                              tvShow.id,
                            ),
                          );

                          ref.invalidate(
                            tvShowWatchStatusProvider(
                              tvShow.id,
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Impossible de modifier la bibliothèque : $error',
                              ),
                            ),
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
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: () async {
            await _showStartSeasonDialog(
              context,
              ref,
            );
          },
          icon: const Icon(
            Icons.play_circle_outline,
          ),
          label: FutureBuilder<int>(
            future: ref
                .read(
                  libraryRepositoryProvider,
                )
                .getSeriesStartSeason(
                  tmdbId: tvShow.id,
                ),
            builder: (
              context,
              snapshot,
            ) {
              final startSeason =
                  snapshot.data ?? 1;

              return Text(
                'Suivi à partir de la saison $startSeason',
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showStartSeasonDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final seasons = await ref.read(
      tvShowSeasonsProvider(tvShow.id).future,
    );

    final regularSeasons = seasons
        .where(
          (season) => season.seasonNumber > 0,
        )
        .toList()
      ..sort(
        (a, b) =>
            a.seasonNumber.compareTo(
          b.seasonNumber,
        ),
      );

    if (!context.mounted ||
        regularSeasons.isEmpty) {
      return;
    }

    final repository = ref.read(
      libraryRepositoryProvider,
    );

    final currentStartSeason =
        await repository.getSeriesStartSeason(
      tmdbId: tvShow.id,
    );

    if (!context.mounted) {
      return;
    }

    int selectedSeason = currentStartSeason;

    if (!regularSeasons.any(
      (season) =>
          season.seasonNumber ==
          selectedSeason,
    )) {
      selectedSeason =
          regularSeasons.first.seasonNumber;
    }

    final result =
        await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setState,
          ) {
            return AlertDialog(
              title: const Text(
                'Commencer le suivi à partir de',
              ),
              content: DropdownButtonFormField<int>(
                value: selectedSeason,
                decoration:
                    const InputDecoration(
                  labelText: 'Saison',
                ),
                items: regularSeasons.map(
                  (season) {
                    return DropdownMenuItem<int>(
                      value: season.seasonNumber,
                      child: Text(
                        'Saison ${season.seasonNumber}',
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedSeason = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Annuler',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(
                      selectedSeason,
                    );
                  },
                  child: const Text(
                    'Enregistrer',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      await repository.setSeriesStartSeason(
        tmdbId: tvShow.id,
        startSeason: result,
        name: tvShow.name,
        posterPath: tvShow.posterPath,
      );

      ref.invalidate(
        tvShowStartSeasonProvider(
          tvShow.id,
        ),
      );

      ref.invalidate(
        tvShowWatchStatusProvider(
          tvShow.id,
        ),
      );

      ref.invalidate(
        tvShowAllEpisodesWatchedProvider(
          tvShow.id,
        ),
      );

      ref.invalidate(
        nextEpisodeProvider(tvShow.id),
      );

      ref.invalidate(
        librarySeriesProvider,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Le suivi commence maintenant à la saison $result.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de modifier la saison de suivi : $error',
          ),
        ),
      );
    }
  }
}