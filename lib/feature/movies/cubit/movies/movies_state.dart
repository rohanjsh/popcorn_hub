part of 'movies_cubit.dart';

/// Base class for all movie-related states.
@immutable
sealed class MoviesState {}

/// Represents the initial state when the movies feature is first loaded.
class MoviesInitial extends MoviesState {}

/// Represents the loading state while fetching movies.
class MoviesLoading extends MoviesState {}

/// Represents the state when movies are successfully loaded.
///
/// This state includes both the list of movies and whether the view
/// is currently filtered to show only favorites.
///
/// Example:
/// ```dart
/// final state = MoviesLoaded([movie1, movie2], isShowingFavorites: true);
/// ```
class MoviesLoaded extends MoviesState {
  /// Creates a new instance of [MoviesLoaded].
  ///
  /// Parameters:
  ///   - [movies]: List of movies to display
  ///   - [isShowingFavorites]: Whether only favorite movies are being shown
  MoviesLoaded(this.movies, {this.isShowingFavorites = false});

  /// The list of movies to display
  final List<Movie> movies;

  /// Indicates if the view is filtered to show only favorites
  final bool isShowingFavorites;
}

/// Represents the state when a search operation is in progress.
class MoviesSearching extends MoviesState {}

/// Represents the state when search results are loaded.
///
/// Example:
/// ```dart
/// final searchResults = MoviesSearchLoaded([movie1, movie2]);
/// ```
class MoviesSearchLoaded extends MoviesState {
  MoviesSearchLoaded(this.movies);
  final List<Movie> movies;
}

/// Represents the offline state where only favorite movies are available.
///
/// This state is used when the app cannot connect to the internet
/// and can only display locally stored favorite movies.
class MoviesOffline extends MoviesState {
  MoviesOffline(this.favoriteMovies);
  final List<Movie> favoriteMovies;
}

/// Represents an error state in the movies feature.
///
/// Example:
/// ```dart
/// final error = MoviesError('Failed to fetch movies');
/// ```
class MoviesError extends MoviesState {
  MoviesError(this.message);
  final String message;
}
