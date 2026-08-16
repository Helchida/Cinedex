import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../authentication/providers/auth_controller.dart';
import '../library/providers/library_provider.dart';
import '../watchlist/providers/watch_progress_provider.dart';
import '../details/providers/media_details_provider.dart';

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
                _ProfileHeader(
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
                    _StatCard(
                      icon: Icons.movie_outlined,
                      value: '$watchedMovies',
                      label: 'Films vus',
                    ),
                    _StatCard(
                      icon: Icons.tv_outlined,
                      value: '$seriesCount',
                      label: 'Séries suivies',
                    ),
                    _StatCard(
                      icon: Icons.play_circle_outline,
                      value: '$watchedEpisodes',
                      label: 'Épisodes vus',
                    ),
                    _StatCard(
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
                      _InfoRow(
                        icon: Icons.movie_outlined,
                        title: 'Films vus',
                        value: '$watchedMovies',
                      ),
                      Divider(
                        height: 24,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      _InfoRow(
                        icon: Icons.bookmark_border,
                        title: 'Films à voir',
                        value: '$watchlistMovies',
                      ),
                      Divider(
                        height: 24,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      _InfoRow(
                        icon: Icons.tv_outlined,
                        title: 'Séries suivies',
                        value: '$seriesCount',
                      ),
                      Divider(
                        height: 24,
                        color:
                            colorScheme.outlineVariant,
                      ),
                      _InfoRow(
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
                      _InfoRow(
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

                _SeriesStatistics(
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.email,
    required this.createdAt,
  });

  final String? email;
  final String? createdAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: colorScheme.primary,
            child: Icon(
              Icons.person,
              size: 38,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Mon profil',
                  style:
                      theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email ?? 'Utilisateur',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style:
                theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 23,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style:
              theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SeriesStatistics extends ConsumerWidget {
  const _SeriesStatistics({
    required this.series,
    required this.watchedEpisodes,
  });

  final List<Map<String, dynamic>> series;
  final Map<int, dynamic> watchedEpisodes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (series.isEmpty) {
      return _EmptySeriesCard();
    }

    return FutureBuilder<_SeriesStats>(
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
          return _SeriesFallbackCard(
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
              _InfoRow(
                icon: Icons.check_circle_outline,
                title: 'Séries terminées',
                value: '${stats.completed}',
              ),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.timelapse_outlined,
                title: 'Séries en cours',
                value: '${stats.inProgress}',
              ),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.remove_red_eye_outlined,
                title: 'Épisodes disponibles',
                value: '${stats.totalEpisodes}',
              ),
              const SizedBox(height: 20),
              _ProgressBar(
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

  Future<_SeriesStats> _calculateSeriesStats(
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

      final regularSeasons = seasons.where(
        (season) => season.seasonNumber > 0,
      );

      var seriesTotalEpisodes = 0;

      for (final season in regularSeasons) {
        seriesTotalEpisodes +=
            season.episodeCount ?? 0;
      }

      final watchedForSeries =
          watchedEpisodes.values.where(
        (episode) =>
            episode.tvShowId == tmdbId,
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

    return _SeriesStats(
      completed: completed,
      inProgress: inProgress,
      totalEpisodes: totalEpisodes,
      watchedEpisodes: totalWatchedEpisodes,
    );
  }
}

class _SeriesStats {
  const _SeriesStats({
    required this.completed,
    required this.inProgress,
    required this.totalEpisodes,
    required this.watchedEpisodes,
  });

  final int completed;
  final int inProgress;
  final int totalEpisodes;
  final int watchedEpisodes;
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final percentage =
        (value * 100).round();

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    theme.textTheme.bodyLarge,
              ),
            ),
            Text(
              '$percentage %',
              style:
                  theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius:
              BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor:
                colorScheme.surface,
          ),
        ),
      ],
    );
  }
}

class _EmptySeriesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color:
            colorScheme.surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.tv_off_outlined,
            size: 42,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune série suivie',
            style:
                theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez une série pour commencer à suivre votre progression.',
            textAlign: TextAlign.center,
            style:
                theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SeriesFallbackCard extends StatelessWidget {
  const _SeriesFallbackCard({
    required this.seriesCount,
    required this.watchedEpisodes,
  });

  final int seriesCount;
  final int watchedEpisodes;

  @override
  Widget build(BuildContext context) {
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
          _InfoRow(
            icon: Icons.tv_outlined,
            title: 'Séries suivies',
            value: '$seriesCount',
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: Icons.play_circle_outline,
            title: 'Épisodes vus',
            value: '$watchedEpisodes',
          ),
        ],
      ),
    );
  }
}