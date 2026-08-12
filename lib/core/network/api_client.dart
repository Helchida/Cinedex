import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.themoviedb.org/3',
            headers: {
              'Authorization':
                  'Bearer ${dotenv.env['TMDB_ACCESS_TOKEN']}',
              'Content-Type': 'application/json',
            },
          ),
        );

  final Dio dio;
}