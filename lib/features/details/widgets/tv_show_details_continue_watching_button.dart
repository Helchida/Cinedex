import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../series/models/tv_show.dart';
import '../pages/season_episodes_page.dart';
import '../../library/providers/next_episode_provider.dart';

class ContinueWatchingButton extends ConsumerWidget {
  const ContinueWatchingButton({
    super.key,
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