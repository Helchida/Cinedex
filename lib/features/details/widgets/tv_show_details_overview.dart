import 'package:flutter/material.dart';
import '../../series/models/tv_show.dart';

class Overview extends StatelessWidget {
  const Overview({
    super.key,
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(BuildContext context) {
    if (tvShow.overview == null ||
        tvShow.overview!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          tvShow.overview!,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(
                height: 1.5,
              ),
        ),
      ],
    );
  }
}