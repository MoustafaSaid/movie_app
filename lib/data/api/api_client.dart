import 'package:dio/dio.dart';
import 'package:dio_pretty_logger/dio_pretty_logger.dart';
import 'movie_api_service.dart';

class ApiClient {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String apiKey =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2YzFiOGYzMDA2ZDhhMWNmNDM3Mzg4ZmE5NzFhMGYwMyIsIm5iZiI6MTc2MTk1NTQ2NS40MDYwMDAxLCJzdWIiOiI2OTA1NGU4OTgxZTM0ZTY1YmFlMTI1ZmEiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.AQv85gB85mj2ac2ZExW1P1fCGdtEJ-6R7IS_rbsfLME'; // Replace with your API key

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add pretty logger interceptor
    dio.interceptors.add(prettyInterceptorsWrapper);

    // Add API key interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $apiKey';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Let Retrofit handle the response deserialization
          // Only validate that we got a response
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log additional error details for debugging
          if (error.type == DioExceptionType.unknown) {
            // The error details will be extracted in the repository
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  static MovieApiService get movieApiService {
    return MovieApiService(createDio(), baseUrl: baseUrl);
  }
}
