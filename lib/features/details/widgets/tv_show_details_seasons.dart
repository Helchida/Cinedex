import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/media_details_provider.dart';
import 'tv_show_details_season_tile.dart';

class Seasons extends ConsumerWidget {
  const Seasons({
    super.key,
    required this.tvShowId,
  });

  final int tvShowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsAsync = ref.watch(
      tvShowSeasonsProvider(tvShowId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saisons',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        seasonsAsync.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          error: (error, stackTrace) {
            return Text(
              'Impossible de charger les saisons.',
            );
          },
          data: (seasons) {
            return Column(
              children: seasons
                  .where(
                    (season) => season.seasonNumber > 0,
                  )
                  .map(
                    (season) => SeasonTile(
                      tvShowId: tvShowId,
                      season: season,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}