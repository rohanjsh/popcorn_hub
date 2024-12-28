import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:popcorn_hub/feature/movies/cubit/search/search_cubit.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  MovieSearchDelegate(this._searchCubit);

  final SearchCubit _searchCubit;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () async {
          if (query.isNotEmpty) {
            await _searchCubit.searchMovies(query);
            if (context.mounted) showResults(context); // Force rebuild results
          }
        },
      ),
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _searchCubit.clearSearch();
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        _searchCubit.clearSearch();
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Immediately trigger search when showing results if we have a query
    if (query.isNotEmpty) {
      _searchCubit.searchMovies(query);
    }

    return BlocConsumer<SearchCubit, SearchState>(
      bloc: _searchCubit,
      listener: (context, state) {
        if (state is SearchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SearchLoaded) {
          if (state.movies.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context).noResultsFound),
            );
          }

          return ListView.builder(
            itemCount: state.movies.length,
            itemBuilder: (context, index) {
              final movie = state.movies[index];
              return ListTile(
                leading: (movie.posterPath ?? '').isNotEmpty
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                        width: 56,
                        errorBuilder: (_, __, ___) => const SizedBox(width: 56),
                      )
                    : const SizedBox(width: 56),
                title: Text(movie.title ?? ''),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)
                          .selectedMovie(movie.title ?? ''),
                    ),
                  ),
                ),
              );
            },
          );
        }

        if (state is SearchError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).searchHintText,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void close(BuildContext context, Movie? result) {
    _searchCubit.clearSearch();
    super.close(context, result);
  }
}
