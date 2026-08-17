import 'package:flutter/material.dart';
import '../../movies/models/movie.dart';
import '../../details/pages/movie_details_page.dart';
import 'search_poster.dart';

class MovieResultTile extends StatelessWidget {
  const MovieResultTile({
    super.key,
    required this.movie,
  });

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Poster(
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