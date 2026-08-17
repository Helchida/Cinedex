import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/media_details_provider.dart';
import '../widgets/season_episode_season_content.dart';

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

              return SeasonContent(
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