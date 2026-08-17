import 'package:flutter/material.dart';

class EmptySearchState extends StatelessWidget {
  const EmptySearchState({super.key});

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