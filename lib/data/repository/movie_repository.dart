import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/error/error_handler.dart';
import '../api/movie_api_service.dart';
import '../models/movie_response_model.dart';
import '../cache/movie_cache.dart';

class MovieRepository {
  final MovieApiService _apiService;

  MovieRepository({required MovieApiService apiService})
    : _apiService = apiService;

  Future<Either<AppError, MovieResponseModel>> getTopRatedMovies({
    required int page,
    bool useCache = true,
  }) async {
    try {
      // Only use cache for page 1
      if (useCache && page == 1) {
        final cachedMovies = await MovieCache.getCachedMovies();
        final isCacheValid = await MovieCache.isCacheValid();

        if (cachedMovies != null && isCacheValid) {
          print('Returning cached movies for page 1');
          final cachedPage = await MovieCache.getCachedPage() ?? 1;
          return Right(
            MovieResponseModel(
              page: cachedPage,
              results: List.from(cachedMovies),
              totalPages: 500, // TMDB API limitation
              totalResults: 10000,
            ),
          );
        }
      }

      // Always fetch from API for pages > 1 or when cache is invalid
      print('Fetching from API - page: $page, useCache: $useCache');

      MovieResponseModel response;
      try {
        response = await _apiService.getTopRatedMovies(page);
      } catch (e, stackTrace) {
        // Catch any parsing or other errors before they become DioException
        print('Error calling getTopRatedMovies:');
        print('  Error: $e');
        print('  StackTrace: $stackTrace');

        // Re-throw as DioException if it isn't already
        if (e is DioException) {
          rethrow;
        }

        // Wrap other errors as DioException for consistent handling
        throw DioException(
          requestOptions: RequestOptions(path: '/movie/top_rated'),
          error: e,
          stackTrace: stackTrace,
          type: DioExceptionType.unknown,
        );
      }

      if (page == 1) {
        await MovieCache.saveMovies(List.from(response.results), page);
      }

      return Right(response);
    } on DioException catch (e) {
      // Log detailed error information for debugging
      if (e.type == DioExceptionType.unknown) {
        print('DioExceptionType.unknown error details:');
        print('  Error: ${e.error}');
        print('  Message: ${e.message}');
        print('  Response: ${e.response?.data}');
        print('  StatusCode: ${e.response?.statusCode}');
        print('  StackTrace: ${e.stackTrace}');

        // If there's a response, try to extract error message
        if (e.response?.data != null) {
          try {
            final errorData = e.response!.data;
            if (errorData is Map<String, dynamic>) {
              print('  Error Data: $errorData');
            }
          } catch (_) {}
        }
      }

      final error = await ErrorHandler.handleDioException(
        e,
        endpoint: '/movie/top_rated',
        additionalContext: {'page': page},
      );

      // Try to return cached data on error if available
      if (useCache && page == 1) {
        final cachedMovies = await MovieCache.getCachedMovies();
        if (cachedMovies != null) {
          final cachedPage = await MovieCache.getCachedPage() ?? 1;
          return Right(
            MovieResponseModel(
              page: cachedPage,
              results: List.from(cachedMovies),
              totalPages: 500,
              totalResults: 10000,
            ),
          );
        }
      }

      return Left(error);
    } on FormatException catch (e) {
      final error = await ErrorHandler.handleFormatException(
        e,
        endpoint: '/movie/top_rated',
        additionalContext: {'page': page},
      );
      return Left(error);
    } on TypeError catch (e) {
      final error = await ErrorHandler.handleTypeError(
        e,
        endpoint: '/movie/top_rated',
        additionalContext: {'page': page},
      );
      return Left(error);
    } catch (e, stackTrace) {
      final error = await ErrorHandler.handleUnknownError(
        e,
        stackTrace,
        endpoint: '/movie/top_rated',
        additionalContext: {'page': page},
      );
      return Left(error);
    }
  }
}
