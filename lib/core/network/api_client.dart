import 'package:dio/dio.dart';

import '../../config/env.dart';

class ApiClient {
  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.themoviedb.org/3',
            headers: {
              'Authorization':
                  'Bearer ${Env.tmdbAccessToken}',
              'Content-Type': 'application/json',
            },
          ),
        );

  final Dio dio;
}