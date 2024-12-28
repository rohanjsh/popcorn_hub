part of 'movies_cubit.dart';

@immutable
sealed class MoviesState {}

class MoviesInitial extends MoviesState {}

class MoviesLoading extends MoviesState {}

class MoviesLoaded extends MoviesState {
  MoviesLoaded(this.movies);
  final List<Movie> movies;
}

class MoviesError extends MoviesState {
  MoviesError(this.message);
  final String message;
}
