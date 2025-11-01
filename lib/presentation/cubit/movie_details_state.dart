part of 'movie_details_cubit.dart';

abstract class MovieDetailsState extends Equatable {
  const MovieDetailsState();

  @override
  List<Object?> get props => [];
}

class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final MovieModel movie;

  const MovieDetailsLoaded(this.movie);

  @override
  List<Object?> get props => [movie];
}

class MovieDetailsError extends MovieDetailsState {
  final AppError error;

  const MovieDetailsError(this.error);

  @override
  List<Object?> get props => [error];
}

