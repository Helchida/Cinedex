import 'package:flutter/material.dart';

class NoResultsState extends StatelessWidget {
  const NoResultsState({super.key});

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