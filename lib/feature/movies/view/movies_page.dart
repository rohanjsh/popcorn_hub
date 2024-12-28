import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:popcorn_hub/feature/connectivity/cubit/connectivity_cubit.dart';
import 'package:popcorn_hub/feature/movies/cubit/movies/movies_cubit.dart';
import 'package:popcorn_hub/feature/movies/cubit/search/search_cubit.dart';
import 'package:popcorn_hub/feature/movies/widgets/movie_grid.dart';
import 'package:popcorn_hub/feature/movies/widgets/movie_search_delegate.dart';
import 'package:popcorn_hub/feature/movies/widgets/offline_message.dart';

/// The main page for displaying trending movies and favorites.
///
/// This page provides the following features:
/// * Display of trending movies in a grid layout
/// * Infinite scrolling for loading more movies
/// * Search functionality
/// * Offline mode support
/// * Favorites toggle and display
///
/// Example usage:
/// ```dart
/// MaterialApp(
///   home: BlocProvider(
///     create: (context) => MoviesCubit(),
///     child: const MoviesPage(),
///   ),
/// )
/// ```
class MoviesPage extends StatefulWidget {
  /// Creates a movies page.
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

/// The state for [MoviesPage].
///
/// Handles:
/// * Scroll controller management
/// * Infinite scrolling logic
/// * UI state management
class _MoviesPageState extends State<MoviesPage> {
  /// Controller for handling scroll events and pagination.
  final _scrollController = ScrollController();

  /// Flag to track if more movies are being loaded.
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<MoviesCubit>().loadMovies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handles scroll events for infinite scrolling.
  ///
  /// Triggers loading of more movies when user scrolls near the bottom of the list.
  void _onScroll() {
    final cubit = context.read<MoviesCubit>();
    if (!_isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      if (cubit.state is MoviesLoaded &&
          (cubit.state as MoviesLoaded).isShowingFavorites) {
        return;
      }
      setState(() => _isLoadingMore = true);
      context.read<MoviesCubit>().loadMore().then(
            (_) => setState(() => _isLoadingMore = false),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocConsumer<ConnectivityCubit, ConnectivityStatus>(
      listener: (context, connectivityState) {
        if (connectivityState == ConnectivityStatus.connected) {
          context.read<MoviesCubit>().loadMovies();
        }
      },
      builder: (context, connectivityState) {
        final isOffline = connectivityState == ConnectivityStatus.disconnected;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.trendingMoviesTitle),
            actions: isOffline
                ? null
                : [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () async {
                        final searchCubit = context.read<SearchCubit>();
                        await showSearch(
                          context: context,
                          delegate: MovieSearchDelegate(searchCubit),
                        );
                      },
                    ),
                    BlocBuilder<MoviesCubit, MoviesState>(
                      buildWhen: (previous, current) =>
                          previous is MoviesLoaded &&
                          current is MoviesLoaded &&
                          previous.isShowingFavorites !=
                              current.isShowingFavorites,
                      builder: (context, state) {
                        return IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: state is MoviesLoaded &&
                                    state.isShowingFavorites
                                ? Colors.red
                                : Colors.grey,
                          ),
                          onPressed: () {
                            context.read<MoviesCubit>().toggleFavoriteFilter();
                          },
                        );
                      },
                    ),
                  ],
          ),
          body: BlocBuilder<MoviesCubit, MoviesState>(
            builder: (context, state) {
              if (isOffline) {
                final favorites = context.read<MoviesCubit>().getFavorites();
                return Column(
                  children: [
                    OfflineMessage(favorites: favorites),
                    if (favorites.isNotEmpty)
                      Expanded(
                        child: MovieGrid(
                          movies: favorites,
                          scrollController: _scrollController,
                          isLoadingMore: false,
                          onFavoritePressed: (movie) {
                            context.read<MoviesCubit>().toggleFavorite(movie);
                          },
                        ),
                      ),
                  ],
                );
              }

              if (state is MoviesInitial ||
                  (state is MoviesLoading && !_isLoadingMore)) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MoviesLoaded) {
                return MovieGrid(
                  movies: state.movies,
                  scrollController: _scrollController,
                  isLoadingMore: _isLoadingMore,
                  onFavoritePressed: (movie) {
                    context.read<MoviesCubit>().toggleFavorite(movie);
                  },
                );
              }

              if (state is MoviesError && !_isLoadingMore) {
                return Center(
                  child: Text(
                    state.message,
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
