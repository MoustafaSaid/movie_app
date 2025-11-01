import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/error/error_handler.dart';
import '../../data/models/movie_model.dart';
import '../../data/repository/movie_repository.dart';

part 'movie_details_state.dart';

class MovieDetailsCubit extends Cubit<MovieDetailsState> {
  final MovieModel movie;

  MovieDetailsCubit(MovieRepository repository, this.movie)
      : super(MovieDetailsLoaded(movie));

  Future<void> loadMovieDetails() async {
    emit(MovieDetailsLoading());
    try {
      // In a real app, you might fetch more details
      // For now, we just emit the loaded state with the movie
      emit(MovieDetailsLoaded(movie));
    } catch (e, stackTrace) {
      // Log to Sentry
      Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      final error = await ErrorHandler.handleUnknownError(
        e,
        stackTrace,
        endpoint: '/movie/${movie.id}',
      );
      emit(MovieDetailsError(error));
    }
  }
}

