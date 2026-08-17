import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_provider.dart';
import '../models/search_result.dart';
import '../widgets/search_empty_state.dart';
import '../widgets/search_no_result_state.dart';
import '../widgets/search_error_state.dart';
import '../widgets/search_explorer_content.dart';
import '../widgets/search_results.dart';

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
    final isSearching =
        _searchController.text.trim().isNotEmpty;

    if (!isSearching) {
      return const ExplorerContent();
    }

    return searchState.when(
      data: (result) {
        if (result == null) {
          return const EmptySearchState();
        }

        if (result.movies.isEmpty &&
            result.tvShows.isEmpty) {
          return const NoResultsState();
        }

        return SearchResults(
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
        return ErrorState(
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