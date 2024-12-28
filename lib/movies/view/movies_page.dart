import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popcorn_hub/connectivity/cubit/connectivity_cubit.dart';
import 'package:popcorn_hub/movies/cubit/movies_cubit.dart';
import 'package:popcorn_hub/movies/cubit/search/search_cubit.dart';
import 'package:popcorn_hub/movies/models/movie.dart';
import 'package:popcorn_hub/movies/widgets/movie_card.dart';
import 'package:popcorn_hub/movies/widgets/movie_search_delegate.dart';

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
    if (!_isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      setState(
        () => _isLoadingMore = true,
      );
      context.read<MoviesCubit>().loadMore().then(
        (_) {
          setState(() => _isLoadingMore = false);
        },
      );
    }
  }

  Widget _buildMovieGrid(List<Movie> movies) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onFavoritePressed: () {
                  context.read<MoviesCubit>().toggleFavorite(movie);
                },
              );
            },
          ),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildOfflineMessage() {
    return const Center(
      child: Text(
        'No Internet Connection',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Movies'),
        actions: [
          BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
            builder: (context, state) {
              if (state == ConnectivityStatus.disconnected) {
                return const SizedBox.shrink();
              }
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      final searchCubit = context.read<SearchCubit>();
                      final movie = await showSearch(
                        context: context,
                        delegate: MovieSearchDelegate(searchCubit),
                      );
                      if (movie != null && mounted) {
                        // Handle selected movie
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      context.read<MoviesCubit>().toggleFavoriteFilter();
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ConnectivityCubit, ConnectivityStatus>(
        listener: (context, connectivityState) {
          if (connectivityState == ConnectivityStatus.connected) {
            context.read<MoviesCubit>().loadMovies();
          }
        },
        builder: (context, connectivityState) {
          return BlocBuilder<MoviesCubit, MoviesState>(
            builder: (context, state) {
              if (connectivityState == ConnectivityStatus.disconnected) {
                final favorites = context.read<MoviesCubit>().getFavorites();
                return favorites.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildOfflineMessage(),
                          const SizedBox(height: 16),
                          const Text('No favorites available offline'),
                        ],
                      )
                    : Column(
                        children: [
                          _buildOfflineMessage(),
                          const SizedBox(height: 16),
                          Expanded(child: _buildMovieGrid(favorites)),
                        ],
                      );
              }

              if (state is MoviesInitial ||
                  (state is MoviesLoading && !_isLoadingMore)) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MoviesLoaded) {
                return _buildMovieGrid(state.movies);
              }

              if (state is MoviesError && !_isLoadingMore) {
                return Center(child: Text(state.message));
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
