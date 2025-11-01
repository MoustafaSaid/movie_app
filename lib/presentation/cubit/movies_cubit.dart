import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/error/error_handler.dart';
import '../../data/models/movie_model.dart';
import '../../data/repository/movie_repository.dart';

part 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  final MovieRepository _repository;

  MoviesCubit(this._repository) : super(MoviesInitial());

  int _currentPage = 1;
  final List<MovieModel> _movies = [];
  bool _isLoadingMore = false;

  Future<void> loadMovies({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _movies.clear();
      _isLoadingMore = false;
      emit(MoviesLoading());
    } else if (state is MoviesLoading) {
      return; // Prevent duplicate loads on initial load
    }

    // Prevent loading more if already loading
    if (_isLoadingMore && !refresh) {
      return;
    }

    try {
      final isInitialLoad = _currentPage == 1 && _movies.isEmpty;

      if (isInitialLoad) {
        emit(MoviesLoading());
      } else if (state is MoviesLoaded || state is MoviesLoadingMore) {
        // Emit loading more state when loading additional pages
        _isLoadingMore = true;
        bool hasMore = false;
        if (state is MoviesLoaded) {
          hasMore = (state as MoviesLoaded).hasMore;
        } else if (state is MoviesLoadingMore) {
          hasMore = (state as MoviesLoadingMore).hasMore;
        }
        emit(MoviesLoadingMore(movies: List.from(_movies), hasMore: hasMore));
      }

      // For pages > 1, always skip cache and fetch from API
      final shouldUseCache = !refresh && _currentPage == 1;

      print(
        'loadMovies called - page: $_currentPage, useCache: $shouldUseCache, refresh: $refresh',
      );

      final result = await _repository.getTopRatedMovies(
        page: _currentPage,
        useCache: shouldUseCache,
      );

      result.fold(
        (error) {
          _isLoadingMore = false;
          print('Error loading movies: ${error.message}');
          if (_movies.isEmpty) {
            emit(MoviesError(error));
          } else {
            // If we have movies, show them and indicate no more pages
            emit(MoviesLoaded(movies: List.from(_movies), hasMore: false));
          }
        },
        (response) {
          _isLoadingMore = false;
          print(
            'Received response - page: ${response.page}, results: ${response.results.length}, totalPages: ${response.totalPages}',
          );

          if (refresh || _currentPage == 1) {
            _movies.clear();
          }
          _movies.addAll(List.from(response.results));

          print('Movies list now has ${_movies.length} items');
          print('Next page will be: ${_currentPage + 1}');

          _currentPage++;

          emit(
            MoviesLoaded(
              movies: List.from(_movies),
              hasMore: _currentPage <= response.totalPages,
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      _isLoadingMore = false;
      // Log to Sentry
      Sentry.captureException(e, stackTrace: stackTrace);
      final error = await ErrorHandler.handleUnknownError(
        e,
        stackTrace,
        endpoint: '/movie/top_rated',
        additionalContext: {'page': _currentPage},
      );
      if (_movies.isEmpty) {
        emit(MoviesError(error));
      } else {
        emit(MoviesLoaded(movies: List.from(_movies), hasMore: false));
      }
    }
  }

  Future<void> refreshMovies() async {
    await loadMovies(refresh: true);
  }

  Future<void> loadMoreMovies() async {
    // Don't load if already loading
    if (_isLoadingMore ||
        state is MoviesLoading ||
        state is MoviesLoadingMore) {
      print('Already loading more, skipping...');
      return;
    }

    // Only load more if we're in loaded state and have more pages
    if (state is MoviesLoaded) {
      final loadedState = state as MoviesLoaded;
      if (loadedState.hasMore) {
        print('Loading more movies - current page: $_currentPage');
        await loadMovies();
      } else {
        print('No more movies to load');
      }
    } else {
      print(
        'Cannot load more - state is not MoviesLoaded: ${state.runtimeType}',
      );
    }
  }
}
