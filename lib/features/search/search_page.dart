import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../movies/models/movie.dart';
import '../series/models/tv_show.dart';
import 'providers/search_provider.dart';
import 'models/search_result.dart';
import '../details/pages/movie_details_page.dart';
import '../details/pages/tv_show_details_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        ref.read(searchProvider.notifier).search(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer'),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _buildResults(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Rechercher un film ou une série...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(
    AsyncValue<SearchResult?> searchState,
  ) {
    return searchState.when(
      data: (result) {
        if (result == null) {
          return const _EmptySearchState();
        }

        if (result.movies.isEmpty && result.tvShows.isEmpty) {
          return const _NoResultsState();
        }

        return _SearchResults(
          movies: result.movies,
          tvShows: result.tvShows,
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      error: (error, stackTrace) {
        return _ErrorState(
          message: error.toString(),
          onRetry: () {
            ref
                .read(searchProvider.notifier)
                .search(_searchController.text);
          },
        );
      },
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Recherchez un film ou une série',
          ),
        ],
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Aucun résultat',
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible de récupérer les résultats.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.movies,
    required this.tvShows,
  });

  final List<Movie> movies;
  final List<TvShow> tvShows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (movies.isNotEmpty) ...[
          const Text(
            'Films',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...movies.map(
            (movie) => _MovieResultTile(movie: movie),
          ),
          const SizedBox(height: 24),
        ],

        if (tvShows.isNotEmpty) ...[
          const Text(
            'Séries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...tvShows.map(
            (show) => _TvShowResultTile(show: show),
          ),
        ],
      ],
    );
  }
}

class _MovieResultTile extends StatelessWidget {
  const _MovieResultTile({
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _Poster(
        path: movie.posterPath,
      ),
      title: Text(movie.title),
      subtitle: Text(
        movie.releaseDate?.year.toString() ?? 'Date inconnue',
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MovieDetailsPage(
              movieId: movie.id,
            ),
          ),
        );
      },
    );
  }
}

class _TvShowResultTile extends StatelessWidget {
  const _TvShowResultTile({
    required this.show,
  });

  final TvShow show;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _Poster(
        path: show.posterPath,
      ),
      title: Text(show.name),
      subtitle: Text(
        show.firstAirDate?.year.toString() ?? 'Date inconnue',
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TvShowDetailsPage(
              tvShowId: show.id,
            ),
          ),
        );
      },
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({
    required this.path,
  });

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return Container(
        width: 50,
        height: 75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.movie_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        'https://image.tmdb.org/t/p/w92$path',
        width: 50,
        height: 75,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 50,
            height: 75,
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            child: const Icon(Icons.broken_image_outlined),
          );
        },
      ),
    );
  }
}