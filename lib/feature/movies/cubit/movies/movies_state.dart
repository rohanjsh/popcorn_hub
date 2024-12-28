part of 'movies_cubit.dart';

@immutable
sealed class MoviesState {}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  MoviesLoaded(this.movies, {this.isShowingFavorites = false});
  final List<Movie> movies;
  final bool isShowingFavorites;
}

class MoviesSearching extends MoviesState {}

class MoviesSearchLoaded extends MoviesState {
  MoviesSearchLoaded(this.movies);
  final List<Movie> movies;
}

class MoviesOffline extends MoviesState {
  MoviesOffline(this.favoriteMovies);
  final List<Movie> favoriteMovies;
}

class MoviesError extends MoviesState {
  MoviesError(this.message);
  final String message;
}
