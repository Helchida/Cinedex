import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../library/providers/next_episode_provider.dart';
import '../../details/pages/season_episodes_page.dart';

class SeriesProgressCard extends ConsumerWidget {
  const SeriesProgressCard({
    super.key,
    required this.tvShowId,
    required this.name,
    required this.posterPath,
  });

  final int tvShowId;
  final String name;
  final String? posterPath;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final nextEpisodeAsync = ref.watch(
      nextEpisodeProvider(tvShowId),
    );

    return nextEpisodeAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) =>
          const SizedBox.shrink(),
      data: (nextEpisode) {
        if (nextEpisode == null) {
          return const SizedBox.shrink();
        }

        final episode = nextEpisode.episode;

        return Card(
          margin: const EdgeInsets.only(
            bottom: 16,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (posterPath != null &&
                  posterPath!.isNotEmpty)
                Image.network(
                  'https://image.tmdb.org/t/p/w500$posterPath',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'S${nextEpisode.seasonNumber.toString().padLeft(2, '0')}'
                      'E${episode.episodeNumber.toString().padLeft(2, '0')}'
                      ' · ${episode.name}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextEpisode.seasonName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SeasonEpisodesPage(
                                tvShowId:
                                    nextEpisode.tvShowId,
                                seasonNumber:
                                    nextEpisode
                                        .seasonNumber,
                                seasonName:
                                    nextEpisode.seasonName,
                                tvShowName: name,
                                posterPath:
                                    posterPath,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                        ),
                        label: const Text(
                          'Continuer',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}