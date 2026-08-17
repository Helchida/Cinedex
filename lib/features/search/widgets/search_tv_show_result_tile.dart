import 'package:flutter/material.dart';
import '../../series/models/tv_show.dart';
import '../../details/pages/tv_show_details_page.dart';
import 'search_poster.dart';

class TvShowResultTile extends StatelessWidget {
  const TvShowResultTile({
    super.key,
    required this.show,
  });

  final TvShow show;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Poster(
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