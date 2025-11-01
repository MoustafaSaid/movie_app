import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/screens/movies_list_screen.dart';
import '../../presentation/screens/movie_details_screen.dart';
import '../../data/models/movie_model.dart';
import '../../data/repository/movie_repository.dart';
import '../../core/di/injection_container.dart';
import '../../presentation/cubit/movie_details_cubit.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'movies',
      builder: (context, state) => const MoviesListScreen(),
    ),
    GoRoute(
      path: '/movie/:id',
      name: 'movie-details',
      builder: (context, state) {
        final movie = state.extra as MovieModel?;
        if (movie == null) {
          return const Scaffold(
            body: Center(child: Text('Movie not found')),
          );
        }
        return BlocProvider(
          create: (context) => MovieDetailsCubit(
            getIt<MovieRepository>(),
            movie,
          ),
          child: const MovieDetailsScreen(),
        );
      },
    ),
  ],
);

