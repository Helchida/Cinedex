import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../series/models/tv_show.dart';
import 'tv_show_details_backdrop.dart';
import 'tv_show_details_header.dart';
import '../../watchlist/providers/watch_progress_provider.dart';
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
            background: Backdrop(
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
                Header(tvShow: tvShow),
                const SizedBox(height: 24),

                ProgressSection(
                  tvShow: tvShow,
                  watchedEpisodes: watchedEpisodes,
                  totalEpisodes: totalEpisodes,
                  progress: progress,
                ),

                const SizedBox(height: 24),

                TvShowDetailsActions(tvShow: tvShow),

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