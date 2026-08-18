import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_info_row.dart';
import '../../details/providers/media_details_provider.dart';
import '../models/series_stats.dart';
import 'profile_progress_bar.dart';
import 'profile_empty_series_card.dart';
import 'profile_series_fallback_card.dart';

class SeriesStatistics extends ConsumerWidget {
  const SeriesStatistics({
    super.key,
    required this.series,
    required this.watchedEpisodes,
  });

  final List<Map<String, dynamic>> series;
  final Map<int, dynamic> watchedEpisodes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (series.isEmpty) {
      return EmptySeriesCard();
    }

    return FutureBuilder<SeriesStats>(
      future: _calculateSeriesStats(
        ref,
        series,
        watchedEpisodes,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError ||
            !snapshot.hasData) {
          return SeriesFallbackCard(
            seriesCount: series.length,
            watchedEpisodes:
                watchedEpisodes.length,
          );
        }

        final stats = snapshot.data!;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              InfoRow(
                icon: Icons.check_circle_outline,
                title: 'Séries terminées',
                value: '${stats.completed}',
              ),
              const SizedBox(height: 20),
              InfoRow(
                icon: Icons.timelapse_outlined,
                title: 'Séries en cours',
                value: '${stats.inProgress}',
              ),
              const SizedBox(height: 20),
              InfoRow(
                icon: Icons.remove_red_eye_outlined,
                title: 'Épisodes disponibles',
                value: '${stats.totalEpisodes}',
              ),
              const SizedBox(height: 20),
              ProgressBar(
                label: 'Progression globale',
                value:
                    stats.totalEpisodes == 0
                        ? 0
                        : stats.watchedEpisodes /
                            stats.totalEpisodes,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<SeriesStats> _calculateSeriesStats(
    WidgetRef ref,
    List<Map<String, dynamic>> series,
    Map<int, dynamic> watchedEpisodes,
  ) async {
    var completed = 0;
    var inProgress = 0;
    var totalEpisodes = 0;
    var totalWatchedEpisodes = 0;

    for (final serie in series) {
      final tmdbId = serie['tmdb_id'];

      if (tmdbId is! int) {
        continue;
      }

      final seasons = await ref.read(
        tvShowSeasonsProvider(tmdbId).future,
      );

      final startSeason = await ref.read(
        tvShowStartSeasonProvider(tmdbId).future,
      );

      final relevantSeasons = seasons.where(
        (season) =>
            season.seasonNumber > 0 &&
            season.seasonNumber >= startSeason,
      );

      var seriesTotalEpisodes = 0;

      for (final season in relevantSeasons) {
        seriesTotalEpisodes +=
            season.episodeCount ?? 0;
      }

      final watchedForSeries =
          watchedEpisodes.values.where(
        (episode) =>
            episode.tvShowId == tmdbId &&
            episode.seasonNumber >= startSeason,
      );

      final seriesWatchedEpisodes =
          watchedForSeries.length;

      totalEpisodes += seriesTotalEpisodes;

      totalWatchedEpisodes +=
          seriesWatchedEpisodes;

      if (seriesTotalEpisodes > 0 &&
          seriesWatchedEpisodes >=
              seriesTotalEpisodes) {
        completed++;
      } else if (seriesWatchedEpisodes > 0) {
        inProgress++;
      }
    }

    return SeriesStats(
      completed: completed,
      inProgress: inProgress,
      totalEpisodes: totalEpisodes,
      watchedEpisodes: totalWatchedEpisodes,
    );
  }
}