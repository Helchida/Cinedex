import 'package:dio/dio.dart';

class ApiClient {
  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.themoviedb.org/3',
            headers: {
              'Authorization':
                  'Bearer ${const String.fromEnvironment('TMDB_ACCESS_TOKEN')}',
              'Content-Type': 'application/json',
            },
          ),
        );

  final Dio dio;
}