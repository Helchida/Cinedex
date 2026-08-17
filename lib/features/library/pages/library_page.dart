import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/library_tab.dart';
import '../widgets/library_movies_library.dart';
import '../widgets/library_series_library.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() =>
      _LibraryPageState();
}

class _LibraryPageState
    extends ConsumerState<LibraryPage> {
  int _selectedType = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma bibliothèque'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          SizedBox(
  width: double.infinity,
  child: Row(
    children: [
      Expanded(
        child: LibraryTab(
          label: 'Films',
          selected: _selectedType == 0,
          onTap: () {
            setState(() {
              _selectedType = 0;
            });
          },
        ),
      ),
      Expanded(
        child: LibraryTab(
          label: 'Séries',
          selected: _selectedType == 1,
          onTap: () {
            setState(() {
              _selectedType = 1;
            });
          },
        ),
      ),
    ],
  ),
),

          const SizedBox(height: 16),

          Expanded(
            child: _selectedType == 0
                ? const MoviesLibrary()
                : const SeriesLibrary(),
          ),
        ],
      ),
    );
  }
}