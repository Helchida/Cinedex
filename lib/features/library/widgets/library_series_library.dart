import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/library_provider.dart';
import 'library_series_card.dart';
import 'library_empty_library.dart';

class SeriesLibrary extends ConsumerWidget {
  const SeriesLibrary();

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final seriesAsync = ref.watch(
      librarySeriesProvider,
    );

    return seriesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Impossible de charger vos séries.\n\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (series) {
        if (series.isEmpty) {
          return const EmptyLibrary(
            icon: Icons.tv_outlined,
            title: 'Aucune série',
            message:
                'Les séries que vous ajoutez à votre bibliothèque apparaîtront ici.',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.62,
          ),
          itemCount: series.length,
          itemBuilder: (context, index) {
            final serie = series[index];

            return SeriesCard(
              tvShowId: serie['tmdb_id'] as int,
              name: serie['name'] as String,
              posterPath:
                  serie['poster_path'] as String?,
            );
          },
        );
      },
    );
  }
}