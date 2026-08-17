import 'package:flutter/material.dart';

import '../../series/models/tv_show.dart';
import '../../details/pages/tv_show_details_page.dart';
import 'search_poster_placeholder.dart';

class ExplorerTvShowCard extends StatelessWidget {
  const ExplorerTvShowCard({
    super.key,
    required this.tvShow,
  });

  final TvShow tvShow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 135,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TvShowDetailsPage(
                tvShowId: tvShow.id,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
                child: tvShow.posterPath != null &&
                        tvShow.posterPath!.isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w342${tvShow.posterPath}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return PosterPlaceholder();
                        },
                      )
                    : PosterPlaceholder(),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              tvShow.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}