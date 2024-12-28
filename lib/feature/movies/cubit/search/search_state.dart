part of 'search_cubit.dart';

/// Represents the base state class for the movie search feature.
///
/// This abstract class serves as the foundation for all possible states
/// in the search functionality of the application.
@immutable
sealed class SearchState {
  const SearchState();
}

/// Represents the initial state of the search feature.
///
/// This state is emitted when the search feature is first initialized
/// or when the search is cleared.
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Represents the loading state during a search operation.
///
/// This state is emitted when a search query is being processed
/// and results are being fetched from the repository.
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// Represents the successful state of a search operation.
///
/// This state contains the list of movies that match the search criteria.
///
/// Example:
/// ```dart
/// final searchResults = SearchLoaded([Movie1, Movie2, Movie3]);
/// ```
class SearchLoaded extends SearchState {
  /// Creates a new instance of [SearchLoaded] with the provided list of movies.
  const SearchLoaded(this.movies);

  /// The list of movies that match the search criteria.
  final List<Movie> movies;
}

/// Represents an error state in the search operation.
///
/// This state is emitted when an error occurs during the search process.
///
/// Example:
/// ```dart
/// final errorState = SearchError('Network connection failed');
/// ```
class SearchError extends SearchState {
  /// Creates a new instance of [SearchError] with the error message.
  const SearchError(this.message);

  /// The error message describing what went wrong.
  final String message;
}
