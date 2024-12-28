import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';
import 'package:popcorn_hub/feature/movies/repository/movies_repository.dart';

part 'movies_state.dart';

/// A Cubit that manages the movie list functionality with persistence support.
///
/// This cubit handles operations related to movies including:
/// - Loading trending movies
/// - Managing favorite movies
/// - Pagination
/// - Offline support
/// - State persistence
///
/// Example usage:
/// ```dart
/// final moviesCubit = MoviesCubit(moviesRepository);
///
/// // Load initial movies
/// await moviesCubit.loadMovies();
///
/// // Toggle favorite status
/// moviesCubit.toggleFavorite(movie);
///
/// // Load more movies (pagination)
/// await moviesCubit.loadMore();
///
/// // Toggle favorites filter
/// moviesCubit.toggleFavoriteFilter();
/// ```
class MoviesCubit extends HydratedCubit<MoviesState> {
  /// Creates a new instance of [MoviesCubit].
  ///
  /// Requires a [MoviesRepository] to handle movie data operations.
  MoviesCubit(this._repository) : super(MoviesInitial());

  final MoviesRepository _repository;
  List<Movie> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _showingFavorites = false;

  /// Restores the cubit state from storage.
  ///
  /// This method is part of the [HydratedBloc] functionality and is called
  /// automatically when the app starts to restore the previous state.
  @override
  MoviesState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['movies'] != null) {
        _movies = (json['movies'] as List)
            .map((m) => Movie.fromJson(m as Map<String, dynamic>))
            .toList();

        if (json['favorites'] != null) {
          final favoriteIds = List<int>.from(json['favorites'] as List);
          for (final movie in _movies) {
            movie.isFavorite = favoriteIds.contains(movie.id);
          }
        }

        return MoviesLoaded(
          _movies,
          isShowingFavorites: _showingFavorites,
        );
      }
    } catch (e) {
      debugPrint('Error loading from storage: $e');
    }
    return null;
  }

  /// Converts the current state to JSON for persistence.
  ///
  /// This method is part of the [HydratedBloc] functionality and is called
  /// automatically when the state changes to persist the new state.
  @override
  Map<String, dynamic>? toJson(MoviesState state) {
    if (state is MoviesLoaded || state is MoviesOffline) {
      final favoriteIds =
          _movies.where((m) => m.isFavorite).map((m) => m.id).toList();

      return {
        'movies': _movies.map((m) => m.toJson()).toList(),
        'favorites': favoriteIds,
      };
    }
    return null;
  }

  /// Loads the initial set of trending movies.
  ///
  /// - Emits [MoviesLoading] while fetching
  /// - On success, emits [MoviesLoaded] with the fetched movies
  /// - On failure, emits [MoviesOffline] with available favorite movies
  Future<void> loadMovies() async {
    try {
      _currentPage = 1;
      emit(MoviesLoading());
      final newMovies = await _repository.getTrendingMovies(_currentPage);

      final existingFavorites = getFavorites();
      for (final movie in newMovies) {
        movie.isFavorite =
            existingFavorites.any((favMovie) => favMovie.id == movie.id);
      }

      _movies = newMovies;
      emit(MoviesLoaded(_movies, isShowingFavorites: _showingFavorites));
    } catch (e) {
      final favorites = getFavorites();
      emit(
        MoviesOffline(favorites),
      );
    }
  }

  /// Toggles the favorite status of a movie.
  ///
  /// Updates the UI state based on whether favorites filter is active.
  ///
  /// Example:
  /// ```dart
  /// moviesCubit.toggleFavorite(movie);
  /// ```
  Future<void> toggleFavorite(Movie movie) async {
    movie.isFavorite = !movie.isFavorite;

    if (state is MoviesLoaded) {
      if (_showingFavorites) {
        emit(MoviesLoaded(getFavorites(), isShowingFavorites: true));
      } else {
        emit(
          MoviesLoaded(
            _movies,
          ),
        );
      }
    } else if (state is MoviesOffline) {
      emit(MoviesOffline(getFavorites()));
    }
  }

  /// Loads the next page of movies (pagination).
  ///
  /// This method handles loading additional movies when the user
  /// scrolls to the end of the current list.
  Future<void> loadMore() async {
    if (_isLoading || state is! MoviesLoaded) return;

    try {
      _isLoading = true;
      final newMovies = await _repository.getTrendingMovies(_currentPage + 1);
      _currentPage++;
      _movies = [..._movies, ...newMovies];
      emit(
        MoviesLoaded(_movies),
      );
    } catch (e) {
      // Show a snackbar or toast
    } finally {
      _isLoading = false;
    }
  }

  /// Returns a list of all favorite movies.
  ///
  /// Example:
  /// ```dart
  /// final favorites = moviesCubit.getFavorites();
  /// ```
  List<Movie> getFavorites() {
    return _movies.where((movie) => movie.isFavorite).toList();
  }

  /// Toggles between showing all movies and showing only favorites.
  ///
  /// Updates the state to reflect the current filter selection.
  void toggleFavoriteFilter() {
    _showingFavorites = !_showingFavorites;
    if (_showingFavorites) {
      emit(MoviesLoaded(getFavorites(), isShowingFavorites: true));
    } else {
      emit(
        MoviesLoaded(
          _movies,
        ),
      );
    }
  }
}
