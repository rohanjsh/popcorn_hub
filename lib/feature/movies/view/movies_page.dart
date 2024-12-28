import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:popcorn_hub/feature/connectivity/cubit/connectivity_cubit.dart';
import 'package:popcorn_hub/feature/movies/cubit/movies/movies_cubit.dart';
import 'package:popcorn_hub/feature/movies/cubit/search/search_cubit.dart';
import 'package:popcorn_hub/feature/movies/widgets/movie_grid.dart';
import 'package:popcorn_hub/feature/movies/widgets/movie_search_delegate.dart';
import 'package:popcorn_hub/feature/movies/widgets/offline_message.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final _scrollController = ScrollController();
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
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      onPressed: () {
                        context.read<MoviesCubit>().toggleFavoriteFilter();
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
