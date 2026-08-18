import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../series/models/tv_show.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
import '../../details/providers/media_details_provider.dart';
import 'tv_show_details_backdrop.dart';
import 'tv_show_details_header.dart';
import 'tv_show_details_progress_section.dart';
import 'tv_show_details_actions.dart';
import 'tv_show_details_genres.dart';
import 'tv_show_details_overview.dart';
import 'tv_show_details_seasons.dart';

class TvShowDetailsContent extends ConsumerWidget {
  const TvShowDetailsContent({
    super.key,
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final watchedEpisodes = ref.watch(
      watchProgressProvider.select(
        (state) => state.episodes.values
            .where(
              (episode) => episode.tvShowId == tvShow.id,
            )
            .length,
      ),
    );

    final startSeasonAsync = ref.watch(
      tvShowStartSeasonProvider(tvShow.id),
    );

    return startSeasonAsync.when(
      loading: () => _buildPage(
        context,
        ref,
        watchedEpisodes: watchedEpisodes,
        totalEpisodes: 0,
        progress: 0,
        loadingProgress: true,
      ),
      error: (_, __) => _buildPage(
        context,
        ref,
        watchedEpisodes: watchedEpisodes,
        totalEpisodes: tvShow.numberOfEpisodes ?? 0,
        progress: 0,
      ),
      data: (startSeason) {
        final seasonsAsync = ref.watch(
          tvShowSeasonsProvider(tvShow.id),
        );

        return seasonsAsync.when(
          loading: () => _buildPage(
            context,
            ref,
            watchedEpisodes: watchedEpisodes,
            totalEpisodes: 0,
            progress: 0,
            loadingProgress: true,
          ),
          error: (_, __) => _buildPage(
            context,
            ref,
            watchedEpisodes: watchedEpisodes,
            totalEpisodes: tvShow.numberOfEpisodes ?? 0,
            progress: 0,
          ),
          data: (seasons) {
            final totalEpisodes = seasons
                .where(
                  (season) =>
                      season.seasonNumber >= startSeason &&
                      season.seasonNumber > 0,
                )
                .fold<int>(
                  0,
                  (total, season) =>
                      total + (season.episodeCount ?? 0),
                );

            final watchedEpisodesFromStartSeason =
                ref.watch(
              watchProgressProvider.select(
                (state) => state.episodes.values
                    .where(
                      (episode) =>
                          episode.tvShowId == tvShow.id &&
                          episode.seasonNumber >= startSeason,
                    )
                    .length,
              ),
            );

            final progress = totalEpisodes == 0
                ? 0.0
                : (watchedEpisodesFromStartSeason /
                        totalEpisodes)
                    .clamp(0.0, 1.0);

            return _buildPage(
              context,
              ref,
              watchedEpisodes:
                  watchedEpisodesFromStartSeason,
              totalEpisodes: totalEpisodes,
              progress: progress,
            );
          },
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    WidgetRef ref, {
    required int watchedEpisodes,
    required int totalEpisodes,
    required double progress,
    bool loadingProgress = false,
  }) {
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
            background: Backdrop(
              path: tvShow.backdropPath,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Header(tvShow: tvShow),

                const SizedBox(height: 24),

                if (loadingProgress)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                else
                  ProgressSection(
                    tvShow: tvShow,
                    watchedEpisodes: watchedEpisodes,
                    totalEpisodes: totalEpisodes,
                    progress: progress,
                  ),

                const SizedBox(height: 24),

                TvShowDetailsActions(
                  tvShow: tvShow,
                ),

                const SizedBox(height: 28),

                Genres(tvShow: tvShow),

                const SizedBox(height: 24),

                Overview(tvShow: tvShow),

                const SizedBox(height: 32),

                Seasons(
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