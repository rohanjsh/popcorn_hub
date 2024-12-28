import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';
import 'package:popcorn_hub/feature/movies/repository/movies_repository.dart';

part 'search_state.dart';

/// A Cubit that manages the movie search functionality.
///
/// This cubit handles the search operations for movies, including fetching
/// search results and managing the search state.
///
/// Example usage:
/// ```dart
/// final searchCubit = SearchCubit(moviesRepository);
///
/// // Perform a search
/// await searchCubit.searchMovies('Avatar');
///
/// // Clear the search
/// searchCubit.clearSearch();
/// ```
class SearchCubit extends Cubit<SearchState> {
  /// Creates a new instance of [SearchCubit].
  ///
  /// Requires a [MoviesRepository] to handle the movie data operations.
  SearchCubit(this._moviesRepository) : super(const SearchInitial());

  final MoviesRepository _moviesRepository;

  /// Searches for movies based on the provided query.
  ///
  /// If the query is empty, it will emit [SearchInitial] state.
  /// During the search, it emits [SearchLoading] state.
  /// On successful search, it emits [SearchLoaded] state with the results.
  /// If an error occurs, it emits [SearchError] state with the error message.
  ///
  /// Parameters:
  ///   - [query]: The search term to look for movies.
  ///
  /// Example:
  /// ```dart
  /// await searchCubit.searchMovies('Star Wars');
  /// ```
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    try {
      final movies = await _moviesRepository.searchMovies(query);
      emit(SearchLoaded(movies));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  /// Clears the current search results and resets to initial state.
  ///
  /// This method emits [SearchInitial] state, effectively clearing
  /// any existing search results.
  ///
  /// Example:
  /// ```dart
  /// searchCubit.clearSearch();
  /// ```
  void clearSearch() {
    emit(const SearchInitial());
  }
}
