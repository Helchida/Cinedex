import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/media_details_provider.dart';
import '../widgets/tv_show_details_content.dart';


class TvShowDetailsPage extends ConsumerWidget {
  const TvShowDetailsPage({
    super.key,
    required this.tvShowId,
  });

  final int tvShowId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tvShowAsync = ref.watch(
      tvShowDetailsProvider(tvShowId),
    );

    return Scaffold(
      body: tvShowAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Impossible de charger la série.\n$error',
              textAlign: TextAlign.center,
            ),
          );
        },
        data: (tvShow) {
          return TvShowDetailsContent(
            tvShow: tvShow,
          );
        },
      ),
    );
  }
}