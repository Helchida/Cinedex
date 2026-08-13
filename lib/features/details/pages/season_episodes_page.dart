import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../watchlist/providers/watch_progress_provider.dart';

import '../../series/models/episode.dart';
import '../providers/media_details_provider.dart';
import '../../watchlist/models/episode_progress.dart';
import '../../watchlist/models/episode_watch_status.dart';

class SeasonEpisodesPage extends ConsumerWidget {
  const SeasonEpisodesPage({
    super.key,
    required this.tvShowId,
    required this.seasonNumber,
    required this.seasonName,
    this.tvShowName,
    this.posterPath,
  });

  final int tvShowId;
  final int seasonNumber;
  final String seasonName;
  final String? tvShowName;
  final String? posterPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final tvShowAsync = ref.watch(
      tvShowDetailsProvider(tvShowId),
    );

    final episodesAsync = ref.watch(
      seasonEpisodesProvider(
        (
          tvShowId: tvShowId,
          seasonNumber: seasonNumber,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(seasonName),
      ),
      body: tvShowAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Impossible de charger la série.',
          ),
        ),
        data: (tvShow) {
          return episodesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                'Impossible de charger les épisodes.\n\n$error',
                textAlign: TextAlign.center,
              ),
            ),
            data: (episodes) {
              if (episodes.isEmpty) {
                return const Center(
                  child: Text(
                    'Aucun épisode trouvé.',
                  ),
                );
              }

              return _SeasonContent(
                episodes: episodes,
                tvShowId: tvShowId,
                seasonNumber: seasonNumber,
                tvShowName: tvShow.name,
                posterPath: tvShow.posterPath,
              );
            },
          );
        },
      )
    );
  }
}

class _EpisodeCard extends ConsumerWidget {
  const _EpisodeCard({
    required this.episode,
    required this.tvShowId,
    required this.tvShowName,
    required this.posterPath,
  });

  final Episode episode;
  final int tvShowId;
  final String tvShowName;
  final String? posterPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWatched = ref.watch(
      watchProgressProvider.select(
        (state) => state.episodes.containsKey(episode.id),
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EpisodeImage(
            path: episode.stillPath,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Épisode ${episode.episodeNumber}',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  episode.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _EpisodeMetadata(
                  episode: episode,
                ),
                if (episode.overview != null &&
                    episode.overview!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    episode.overview!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                _WatchButton(
                  episode: episode,
                  isWatched: isWatched,
                  onPressed: () {
                    ref.read(watchProgressProvider.notifier).toggleEpisode(
                      episodeId: episode.id,
                      tvShowId: tvShowId,
                      seasonNumber: episode.seasonNumber,
                      episodeNumber: episode.episodeNumber,
                      tvShowName: tvShowName,
                      posterPath: posterPath,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeImage extends StatelessWidget {
  const _EpisodeImage({
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          child: const Center(
            child: Icon(
              Icons.movie_outlined,
              size: 48,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        'https://image.tmdb.org/t/p/w500$path',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EpisodeMetadata extends StatelessWidget {
  const _EpisodeMetadata({
    required this.episode,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[];

    if (episode.airDate != null) {
      metadata.add(
        '${episode.airDate!.day.toString().padLeft(2, '0')}/'
        '${episode.airDate!.month.toString().padLeft(2, '0')}/'
        '${episode.airDate!.year}',
      );
    }

    if (episode.runtime != null) {
      metadata.add('${episode.runtime} min');
    }

    if (episode.voteAverage != null &&
        episode.voteAverage! > 0) {
      metadata.add(
        '★ ${episode.voteAverage!.toStringAsFixed(1)}',
      );
    }

    if (metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      metadata.join(' · '),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _WatchButton extends StatelessWidget {
  const _WatchButton({
    required this.episode,
    required this.isWatched,
    required this.onPressed,
  });

  final Episode episode;
  final bool isWatched;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isWatched
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.check),
              label: const Text('Vu'),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.check),
              label: const Text('Marquer comme vu'),
            ),
    );
  }
}

class _SeasonContent extends ConsumerWidget {
  const _SeasonContent({
    required this.episodes,
    required this.tvShowId,
    required this.seasonNumber,
    required this.tvShowName,
    required this.posterPath,
  });

  final List<Episode> episodes;
  final int tvShowId;
  final int seasonNumber;
  final String tvShowName;
  final String? posterPath;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final watchedCount = ref.watch(
      watchProgressProvider.select(
        (state) {
          return state.episodes.values
              .where(
                (progress) =>
                    progress.tvShowId == tvShowId &&
                    progress.seasonNumber == seasonNumber,
              )
              .length;
        },
      ),
    );

    final totalCount = episodes.length;

    final allWatched =
        watchedCount == totalCount;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SeasonProgressHeader(
          watchedCount: watchedCount,
          totalCount: totalCount,
          allWatched: allWatched,
          onToggle: () {
            final episodeProgress =
                episodes.map(
              (episode) {
                return EpisodeProgress(
                  episodeId: episode.id,
                  tvShowId: tvShowId,
                  seasonNumber: seasonNumber,
                  episodeNumber: episode.episodeNumber,
                  status: EpisodeWatchStatus.watched,
                );
              },
            ).toList();

            ref
                .read(watchProgressProvider.notifier)
                .setSeasonWatched(
                  tvShowId: tvShowId,
                  seasonNumber: seasonNumber,
                  episodes: episodeProgress,
                  watched: !allWatched,
                  tvShowName: tvShowName,
                  posterPath: posterPath,
                );
          },
        ),
        const SizedBox(height: 20),
        ...episodes.map(
          (episode) => Padding(
            padding: const EdgeInsets.only(
              bottom: 16,
            ),
            child: _EpisodeCard(
              episode: episode,
              tvShowId: tvShowId,
              tvShowName: tvShowName,
              posterPath: posterPath,
            ),
          ),
        ),
      ],
    );
  }
}

class _SeasonProgressHeader extends StatelessWidget {
  const _SeasonProgressHeader({
    required this.watchedCount,
    required this.totalCount,
    required this.allWatched,
    required this.onToggle,
  });

  final int watchedCount;
  final int totalCount;
  final bool allWatched;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0
        ? 0.0
        : watchedCount / totalCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$watchedCount / $totalCount épisodes vus',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius:
                  BorderRadius.circular(10),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: allWatched
                  ? OutlinedButton.icon(
                      onPressed: onToggle,
                      icon: const Icon(
                        Icons.remove_done,
                      ),
                      label: const Text(
                        'Tout marquer comme non vu',
                      ),
                    )
                  : FilledButton.icon(
                      onPressed: onToggle,
                      icon: const Icon(
                        Icons.done_all,
                      ),
                      label: const Text(
                        'Marquer toute la saison comme vue',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}