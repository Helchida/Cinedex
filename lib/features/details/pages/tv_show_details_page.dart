import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../series/models/season.dart';
import '../../series/models/tv_show.dart';
import '../providers/media_details_provider.dart';
import 'season_episodes_page.dart';
import '../../library/providers/library_provider.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import '../../library/providers/library_repository_provider.dart';
import '../../library/providers/next_episode_provider.dart';

class TvShowDetailsPage extends ConsumerWidget {
  const TvShowDetailsPage({
    super.key,
    required this.tvShowId,
  });

  final int tvShowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tvShowAsync = ref.watch(
      tvShowDetailsProvider(tvShowId),
    );

    return Scaffold(
      body: tvShowAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Impossible de charger la série.\n$error',
              textAlign: TextAlign.center,
            ),
          );
        },
        data: (tvShow) {
          return _TvShowDetailsContent(
            tvShow: tvShow,
          );
        },
      ),
    );
  }
}

class _TvShowDetailsContent extends ConsumerWidget {
  const _TvShowDetailsContent({
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final watchedEpisodes = ref.watch(
      watchProgressProvider.select(
        (state) => state.episodes.values
            .where(
              (episode) => episode.tvShowId == tvShow.id,
            )
            .length,
      ),
    );

    final totalEpisodes = tvShow.numberOfEpisodes ?? 0;

    final progress = totalEpisodes == 0
        ? 0.0
        : watchedEpisodes / totalEpisodes;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _Backdrop(
              path: tvShow.backdropPath,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(tvShow: tvShow),
                const SizedBox(height: 24),

                _ProgressSection(
                  tvShow: tvShow,
                  watchedEpisodes: watchedEpisodes,
                  totalEpisodes: totalEpisodes,
                  progress: progress,
                ),

                const SizedBox(height: 24),

                _Actions(tvShow: tvShow),

                const SizedBox(height: 28),

                _Genres(tvShow: tvShow),
                const SizedBox(height: 24),
                _Overview(tvShow: tvShow),
                const SizedBox(height: 32),
                _Seasons(
                  tvShowId: tvShow.id,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tvShow.posterPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://image.tmdb.org/t/p/w342${tvShow.posterPath}',
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tvShow.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (tvShow.voteAverage != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tvShow.voteAverage!.toStringAsFixed(1),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                [
                  if (tvShow.firstAirDate != null)
                    tvShow.firstAirDate!.year.toString(),
                  if (tvShow.numberOfSeasons != null)
                    '${tvShow.numberOfSeasons} saisons',
                  if (tvShow.numberOfEpisodes != null)
                    '${tvShow.numberOfEpisodes} épisodes',
                ].join(' · '),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressSection extends ConsumerWidget {
  const _ProgressSection({
    required this.tvShow,
    required this.watchedEpisodes,
    required this.totalEpisodes,
    required this.progress,
  });

  final TvShow tvShow;
  final int watchedEpisodes;
  final int totalEpisodes;
  final double progress;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    if (totalEpisodes == 0) {
      return const SizedBox.shrink();
    }

    final percentage = (progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Progression',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '$percentage %',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '$watchedEpisodes / $totalEpisodes épisodes vus',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 16),

            if (watchedEpisodes == totalEpisodes)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.check),
                  label: const Text(
                    'Série terminée',
                  ),
                ),
              )
            else
              _ContinueWatchingButton(
                tvShow: tvShow,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContinueWatchingButton extends ConsumerWidget {
  const _ContinueWatchingButton({
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final nextEpisodeAsync = ref.watch(
      nextEpisodeProvider(tvShow.id),
    );

    return nextEpisodeAsync.when(
      loading: () {
        return const SizedBox(
          width: double.infinity,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return const SizedBox.shrink();
      },
      data: (nextEpisode) {
        if (nextEpisode == null) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SeasonEpisodesPage(
                    tvShowId: tvShow.id,
                    seasonNumber: nextEpisode.seasonNumber,
                    seasonName: nextEpisode.seasonName,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.play_arrow,
            ),
            label: Text(
              'Continuer à regarder · '
              'S${nextEpisode.seasonNumber.toString().padLeft(2, '0')}'
              'E${nextEpisode.episode.episodeNumber.toString().padLeft(2, '0')}',
            ),
          ),
        );
      },
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({
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

class _Genres extends StatelessWidget {
  const _Genres({
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(BuildContext context) {
    if (tvShow.genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tvShow.genres
          .map(
            (genre) => Chip(
              label: Text(genre),
            ),
          )
          .toList(),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(BuildContext context) {
    if (tvShow.overview == null ||
        tvShow.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          tvShow.overview!,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.tv,
            color: Colors.white,
            size: 64,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://image.tmdb.org/t/p/w780$path',
          fit: BoxFit.cover,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Seasons extends ConsumerWidget {
  const _Seasons({
    required this.tvShowId,
  });

  final int tvShowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(
      tvShowSeasonsProvider(tvShowId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saisons',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        seasonsAsync.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return Text(
              'Impossible de charger les saisons.',
            );
          },
          data: (seasons) {
            return Column(
              children: seasons
                  .where(
                    (season) => season.seasonNumber > 0,
                  )
                  .map(
                    (season) => _SeasonTile(
                      tvShowId: tvShowId,
                      season: season,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SeasonTile extends ConsumerWidget {
  const _SeasonTile({
    required this.tvShowId,
    required this.season,
  });

  final int tvShowId;
  final Season season;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final watchedEpisodes = ref.watch(
      watchProgressProvider.select(
        (state) => state.episodes.values
            .where(
              (episode) =>
                  episode.tvShowId == tvShowId &&
                  episode.seasonNumber ==
                      season.seasonNumber,
            )
            .length,
      ),
    );

    final totalEpisodes =
        season.episodeCount ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: _SeasonPoster(
          path: season.posterPath,
        ),
        title: Text(
          season.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          [
            if (totalEpisodes > 0)
              '$watchedEpisodes / $totalEpisodes épisodes vus',
            if (season.airDate != null)
              season.airDate!.year.toString(),
          ].join(' · '),
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SeasonEpisodesPage(
                tvShowId: tvShowId,
                seasonNumber: season.seasonNumber,
                seasonName: season.name,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SeasonPoster extends StatelessWidget {
  const _SeasonPoster({
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        width: 55,
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.tv),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        'https://image.tmdb.org/t/p/w185$path',
        width: 55,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }
}