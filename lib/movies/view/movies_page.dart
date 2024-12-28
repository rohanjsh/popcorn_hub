import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final searchCubit = context.read<SearchCubit>();
              final movie = await showSearch(
                context: context,
                delegate: MovieSearchDelegate(searchCubit),
              );
              if (movie != null && mounted) {
                // Handle selected movie (e.g., navigate to details)
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
      ),
      body: BlocBuilder<MoviesCubit, MoviesState>(
        builder: (context, state) {
          if (state is MoviesInitial ||
              (state is MoviesLoading && !_isLoadingMore)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoviesOffline) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Device offline, but you can still view your favourites',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(child: _buildMovieGrid(state.favoriteMovies)),
              ],
            );
          }

          if (state is MoviesError && !_isLoadingMore) {
            return Center(child: Text(state.message));
          }

          if (state is MoviesLoaded) {
            return _buildMovieGrid(state.movies);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
