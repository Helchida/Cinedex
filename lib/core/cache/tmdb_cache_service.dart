import 'dart:convert';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class TmdbCacheService {
  TmdbCacheService();

  static const String boxName = 'tmdb_cache';

  Box get _box => Hive.box(boxName);

  Future<void> save({
    required String key,
    required dynamic data,
    required Duration duration,
  }) async {
    await _box.put(
      key,
      {
        'cachedAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now()
            .add(duration)
            .toIso8601String(),
        'data': jsonEncode(data),
      },
    );
  }

  dynamic get(String key) {
    final value = _box.get(key);

    if (value == null) {
      return null;
    }

    final expiresAt = DateTime.tryParse(
      value['expiresAt'] as String? ?? '',
    );

    if (expiresAt == null ||
        DateTime.now().isAfter(expiresAt)) {
      _box.delete(key);
      return null;
    }

    return jsonDecode(
      value['data'] as String,
    );
  }

  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}