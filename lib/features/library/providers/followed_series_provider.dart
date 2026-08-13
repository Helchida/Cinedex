import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/followed_series.dart';

class FollowedSeriesNotifier
    extends Notifier<List<FollowedSeries>> {
  @override
  List<FollowedSeries> build() {
    return [];
  }

  void add(FollowedSeries series) {
    if (state.any((item) => item.id == series.id)) {
      return;
    }

    state = [
      ...state,
      series,
    ];
  }

  void remove(int tvShowId) {
    state = state
        .where(
          (series) => series.id != tvShowId,
        )
        .toList();
  }

  bool contains(int tvShowId) {
    return state.any(
      (series) => series.id == tvShowId,
    );
  }
}

final followedSeriesProvider =
    NotifierProvider<
      FollowedSeriesNotifier,
      List<FollowedSeries>
    >(
      FollowedSeriesNotifier.new,
    );