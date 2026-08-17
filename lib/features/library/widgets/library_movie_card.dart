import 'package:flutter/material.dart';
import '../../details/pages/movie_details_page.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movieId,
    required this.title,
    required this.posterPath,
  });

  final int movieId;
  final String title;
  final String? posterPath;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MovieDetailsPage(
                movieId: movieId,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: posterPath != null &&
                      posterPath!.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500$posterPath',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Icon(
                        Icons.movie_outlined,
                        size: 48,
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}