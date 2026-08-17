import 'package:flutter/material.dart';
import '../../series/models/tv_show.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tvShow.posterPath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://image.tmdb.org/t/p/w342${tvShow.posterPath}',
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tvShow.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              if (tvShow.voteAverage != null)
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tvShow.voteAverage!.toStringAsFixed(1),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                [
                  if (tvShow.firstAirDate != null)
                    tvShow.firstAirDate!.year.toString(),
                  if (tvShow.numberOfSeasons != null)
                    '${tvShow.numberOfSeasons} saisons',
                  if (tvShow.numberOfEpisodes != null)
                    '${tvShow.numberOfEpisodes} épisodes',
                ].join(' · '),
              ),
            ],
          ),
        ),
      ],
    );
  }
}