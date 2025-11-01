import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection_container.dart';
import '../../data/models/movie_model.dart';
import '../../data/repository/movie_repository.dart';
import '../cubit/movies_cubit.dart';
import '../cubit/theme_cubit.dart';
import '../widgets/movie_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';

class MoviesListScreen extends StatefulWidget {
  const MoviesListScreen({super.key});

  @override
  State<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends State<MoviesListScreen> {
  final ScrollController _scrollController = ScrollController();
  MoviesCubit? _cubit;
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !mounted || _cubit == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Trigger load when 90% scrolled and not already at the bottom
    if (maxScroll > 0 &&
        currentScroll >= maxScroll * 0.9 &&
        currentScroll < maxScroll) {
      // Only trigger if state allows it
      final state = _cubit!.state;
      if (state is MoviesLoaded && state.hasMore) {
        _cubit!.loadMoreMovies();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

    return BlocProvider<MoviesCubit>(
      create: (context) => MoviesCubit(getIt<MovieRepository>())..loadMovies(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Icon(Icons.movie, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Movies'),
              const Spacer(),
              IconButton(
                icon: Icon(
                  themeCubit.state.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Colors.blue,
                ),
                onPressed: () => themeCubit.toggleTheme(),
              ),
            ],
          ),
        ),
        body: BlocConsumer<MoviesCubit, MoviesState>(
          listener: (context, state) {
            // Store cubit reference when available
            _cubit = context.read<MoviesCubit>();
            // Set up scroll listener once cubit is available
            if (!_listenerAdded) {
              _scrollController.addListener(_onScroll);
              _listenerAdded = true;
            }
          },
          builder: (context, state) {
            // Store cubit reference for scroll listener
            _cubit = context.read<MoviesCubit>();

            if (state is MoviesLoading) {
              return const LoadingIndicator();
            }

            if (state is MoviesError) {
              return ErrorWidgetView(
                message: state.error.message,
                onRetry: () => context.read<MoviesCubit>().refreshMovies(),
              );
            }

            // Handle both MoviesLoaded and MoviesLoadingMore states
            List<MovieModel> movies;
            bool hasMore;

            if (state is MoviesLoaded) {
              movies = state.movies;
              hasMore = state.hasMore;
            } else if (state is MoviesLoadingMore) {
              movies = state.movies;
              hasMore = state.hasMore;
            } else {
              return const LoadingIndicator();
            }

            if (movies.isNotEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<MoviesCubit>().refreshMovies();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: movies.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= movies.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final movie = movies[index];
                    return MovieCard(
                      movie: movie,
                      onTap: () {
                        context.pushNamed(
                          'movie-details',
                          pathParameters: {'id': movie.id.toString()},
                          extra: movie,
                        );
                      },
                    );
                  },
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No movies found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<MoviesCubit>().refreshMovies(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
