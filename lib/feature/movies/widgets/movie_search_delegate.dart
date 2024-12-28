import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:popcorn_hub/feature/movies/cubit/search/search_cubit.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';

/// A search delegate that handles movie search functionality.
///
/// This delegate provides a search interface for movies, including:
/// * Search suggestions
/// * Search results display
/// * Error handling
/// * Loading states
///
/// Example usage:
/// ```dart
/// showSearch(
///   context: context,
///   delegate: MovieSearchDelegate(searchCubit),
/// );
/// ```
class MovieSearchDelegate extends SearchDelegate<Movie?> {
  /// Creates a movie search delegate.
  ///
  /// Requires a [SearchCubit] instance to handle the search state management.
  MovieSearchDelegate(this._searchCubit);

  /// The cubit responsible for managing the search state.
  final SearchCubit _searchCubit;

  /// Builds the actions shown in the search bar.
  ///
  /// Returns a list of widgets that includes:
  /// * A search button that triggers the search
  /// * A clear button that appears when there's text input
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

  /// Builds the leading widget in the search bar.
  ///
  /// Returns a back button that clears the search and closes the search interface.
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

  /// Builds the search results view.
  ///
  /// Shows different widgets based on the search state:
  /// * Loading indicator while searching
  /// * List of movie results when search is complete
  /// * Error message if search fails
  /// * Empty message if no results found
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
                    ? CachedNetworkImage(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w92${movie.posterPath}',
                        width: 56,
                        placeholder: (context, url) => const SizedBox(
                          width: 56,
                        ),
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

  /// Builds the search suggestions view.
  ///
  /// Displays a centered search icon and hint text when no search is performed.
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

  /// Closes the search interface and clears the search state.
  ///
  /// This override ensures the search state is cleared when the search interface is closed.
  @override
  void close(BuildContext context, Movie? result) {
    _searchCubit.clearSearch();
    super.close(context, result);
  }
}
