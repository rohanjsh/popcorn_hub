import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:popcorn_hub/movies/models/movie.dart';
import 'package:popcorn_hub/movies/repository/movies_repository.dart';

part 'movies_state.dart';

class MoviesCubit extends HydratedCubit<MoviesState> {
  MoviesCubit(this._repository) : super(MoviesInitial());
  final MoviesRepository _repository;
  List<Movie> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;

  @override
  MoviesState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['movies'] != null) {
        final movies = (json['movies'] as List)
            .map((m) => Movie.fromJson(m as Map<String, dynamic>))
            .toList();
        return MoviesLoaded(movies);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(MoviesState state) {
    if (state is MoviesLoaded) {
      return {
        'movies': state.movies.map((m) => m.toJson()).toList(),
      };
    }
    return null;
  }

  Future<void> loadMovies() async {
    try {
      _currentPage = 1; // Reset page when loading fresh
      emit(MoviesLoading());
      _movies = await _repository.getTrendingMovies(_currentPage);
      emit(MoviesLoaded(_movies));
    } catch (e) {
      emit(MoviesError('Failed to load movies'));
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    movie.isFavorite = !movie.isFavorite;
    if (state is MoviesLoaded) {
      emit(MoviesLoaded(List.from(_movies)));
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || state is! MoviesLoaded) return;

    try {
      _isLoading = true;
      final newMovies = await _repository.getTrendingMovies(_currentPage + 1);
      _currentPage++;
      _movies = [..._movies, ...newMovies];
      emit(MoviesLoaded(_movies));
    } catch (e) {
      // Don't emit error on pagination failure
      // Optionally show a snackbar or toast
    } finally {
      _isLoading = false;
    }
  }

  List<Movie> searchMovies(String query) {
    if (query.isEmpty) return _movies;
    return _movies
        .where(
          (movie) => movie.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  List<Movie> getFavorites() {
    return _movies.where((movie) => movie.isFavorite).toList();
  }
}
