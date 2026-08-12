import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../series/models/episode.dart';
import '../providers/media_details_provider.dart';

class SeasonEpisodesPage extends ConsumerWidget {
  const SeasonEpisodesPage({
    super.key,
    required this.tvShowId,
    required this.seasonNumber,
    required this.seasonName,
  });

  final int tvShowId;
  final int seasonNumber;
  final String seasonName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      body: episodesAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Impossible de charger les épisodes.\n\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        data: (episodes) {
          if (episodes.isEmpty) {
            return const Center(
              child: Text(
                'Aucun épisode trouvé.',
              ),
            );
          }

          return _EpisodesList(
            episodes: episodes,
          );
        },
      ),
    );
  }
}

class _EpisodesList extends StatelessWidget {
  const _EpisodesList({
    required this.episodes,
  });

  final List<Episode> episodes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: episodes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _EpisodeCard(
          episode: episodes[index],
        );
      },
    );
  }
}

class _EpisodeCard extends StatelessWidget {
  const _EpisodeCard({
    required this.episode,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context) {
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          height: 1.4,
                        ),
                  ),
                ],
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