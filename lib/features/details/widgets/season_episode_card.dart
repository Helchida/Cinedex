import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../series/models/episode.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import 'season_episode_image.dart';
import 'season_episode_metadata.dart';
import 'season_episode_watch_button.dart';

class EpisodeCard extends ConsumerWidget {
  const EpisodeCard({
    super.key,
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
          EpisodeImage(
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
                EpisodeMetadata(
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
                WatchButton(
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