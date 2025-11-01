import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import '../../data/api/movie_api_service.dart';
import '../../data/repository/movie_repository.dart';
import '../../data/cache/movie_cache.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection container
Future<void> initDependencyInjection() async {
  // Initialize Hive cache
  await MovieCache.init();

  // Register Dio instance
  getIt.registerLazySingleton<Dio>(
    () => _createDio(),
  );

  // Register API services
  getIt.registerLazySingleton<MovieApiService>(
    () => MovieApiService(
      getIt<Dio>(),
      baseUrl: _baseUrl,
    ),
  );

  // Register repositories
  getIt.registerLazySingleton<MovieRepository>(
    () => MovieRepository(
      apiService: getIt<MovieApiService>(),
    ),
  );
}

const String _baseUrl = 'https://api.themoviedb.org/3';
const String _apiKey =
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2YzFiOGYzMDA2ZDhhMWNmNDM3Mzg4ZmE5NzFhMGYwMyIsIm5iZiI6MTc2MTk1NTQ2NS40MDYwMDAxLCJzdWIiOiI2OTA1NGU4OTgxZTM0ZTY1YmFlMTI1ZmEiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.AQv85gB85mj2ac2ZExW1P1fCGdtEJ-6R7IS_rbsfLME';

Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add API key interceptor first (before logger)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $_apiKey';
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Pass response through unchanged
        return handler.next(response);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ),
  );

  // Add logger interceptor last (only in debug mode)
  // Using Dio's built-in logger instead of dio_pretty_logger to avoid conflicts with Retrofit
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        logPrint: (obj) {
          print(obj);
        },
      ),
    );
  }

  return dio;
}

