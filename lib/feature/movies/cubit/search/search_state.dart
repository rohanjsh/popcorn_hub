part of 'search_cubit.dart';

@immutable
sealed class SearchState {
  const SearchState();
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  const SearchLoaded(this.movies);
  final List<Movie> movies;
}

class SearchError extends SearchState {
  const SearchError(this.message);
  final String message;
}
