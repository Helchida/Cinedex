import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../authentication/providers/auth_controller.dart';
import '../../library/providers/library_provider.dart';
import '../../watchlist/providers/watch_progress_provider.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_info_row.dart';
import '../widgets/profile_series_statistics.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final user = Supabase.instance.client.auth.currentUser;

    final watchProgress = ref.watch(watchProgressProvider);
    final moviesAsync = ref.watch(libraryMoviesProvider);
    final seriesAsync = ref.watch(librarySeriesProvider);

    final isLoading =
        watchProgress.isLoading ||
        moviesAsync.isLoading ||
        seriesAsync.isLoading;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final series = seriesAsync.value ?? [];

    final watchedMovies = watchProgress.movies.length;
    final watchlistMovies =
        watchProgress.movieWatchlist.length;

    final watchedEpisodes =
        watchProgress.episodes.length;

    final seriesCount = series.length;

    final totalMedia =
        watchedMovies +
        watchlistMovies +
        seriesCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(libraryMoviesProvider);
            ref.invalidate(librarySeriesProvider);
            ref.invalidate(watchProgressProvider);

            await Future.wait([
              ref.read(libraryMoviesProvider.future),
              ref.read(librarySeriesProvider.future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileHeader(
                  email: user?.email,
                  createdAt: user?.createdAt,
                ),

                const SizedBox(height: 28),

                Text(
                  'Mes statistiques',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    StatCard(
                      icon: Icons.movie_outlined,
                      value: '$watchedMovies',
                      label: 'Films vus',
                    ),
                    StatCard(
                      icon: Icons.tv_outlined,
                      value: '$seriesCount',
                      label: 'Séries suivies',
                    ),
                    StatCard(
                      icon: Icons.play_circle_outline,
                      value: '$watchedEpisodes',
                      label: 'Épisodes vus',
                    ),
                    StatCard(
                      icon: Icons.bookmark_outline,
                      value: '$watchlistMovies',
                      label: 'Films à voir',
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  'Mon activité',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.movie_outlined,
                        title: 'Films vus',
                        value: '$watchedMovies',
                      ),
                      Divider(
                        height: 24,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      InfoRow(
                        icon: Icons.bookmark_border,
                        title: 'Films à voir',
                        value: '$watchlistMovies',
                      ),
                      Divider(
                        height: 24,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      InfoRow(
                        icon: Icons.tv_outlined,
                        title: 'Séries suivies',
                        value: '$seriesCount',
                      ),
                      Divider(
                        height: 24,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      InfoRow(
                        icon:
                            Icons.play_circle_outline,
                        title: 'Épisodes regardés',
                        value: '$watchedEpisodes',
                      ),
                      Divider(
                        height: 24,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      InfoRow(
                        icon: Icons.video_library_outlined,
                        title: 'Médias suivis',
                        value: '$totalMedia',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'Mes séries',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                SeriesStatistics(
                  series: series,
                  watchedEpisodes:
                      watchProgress.episodes,
                ),

                const SizedBox(height: 28),

                Text(
                  'Compte',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.email_outlined,
                        ),
                        title: const Text(
                          'Adresse email',
                        ),
                        subtitle: Text(
                          user?.email ??
                              'Adresse inconnue',
                        ),
                      ),
                      Divider(
                        height: 1,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.calendar_today_outlined,
                        ),
                        title: const Text(
                          'Membre depuis',
                        ),
                        subtitle: Text(
                          _formatDate(
                            user?.createdAt,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: colorScheme.error,
                        ),
                        title: Text(
                          'Se déconnecter',
                          style: TextStyle(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () async {
                          await _signOut(
                            context,
                            ref,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .signOut();
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de se déconnecter.',
          ),
        ),
      );
    }
  }

  String _formatDate(String? date) {
    if (date == null) {
      return 'Inconnue';
    }

    final parsed = DateTime.tryParse(date);

    if (parsed == null) {
      return 'Inconnue';
    }

    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/'
        '${parsed.year}';
  }
}