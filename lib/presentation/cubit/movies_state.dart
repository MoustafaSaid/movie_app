part of 'movies_cubit.dart';

abstract class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoadingMore extends MoviesState {
  final List<MovieModel> movies;
  final bool hasMore;

  const MoviesLoadingMore({
    required this.movies,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [movies, hasMore];
}

class MoviesLoaded extends MoviesState {
  final List<MovieModel> movies;
  final bool hasMore;

  const MoviesLoaded({
    required this.movies,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [movies, hasMore];
}

class MoviesError extends MoviesState {
  final AppError error;

  const MoviesError(this.error);

  @override
  List<Object?> get props => [error];
}

