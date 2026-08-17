import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/next_episode_provider.dart';
import '../../details/pages/tv_show_details_page.dart';

class SeriesCard extends ConsumerWidget {
  const SeriesCard({
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
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (nextEpisode) {
        final isCompleted = nextEpisode == null;

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TvShowDetailsPage(
                    tvShowId: tvShowId,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: posterPath != null &&
                          posterPath!.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w500$posterPath',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(
                            Icons.tv_outlined,
                            size: 48,
                          ),
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    10,
                    10,
                    4,
                  ),
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    0,
                    10,
                    10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.play_circle_outline,
                        size: 17,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          isCompleted
                              ? 'Terminée'
                              : 'En cours',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}