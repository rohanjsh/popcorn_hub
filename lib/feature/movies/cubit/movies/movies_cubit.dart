import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';
import 'package:popcorn_hub/feature/movies/repository/movies_repository.dart';

part 'movies_state.dart';

class MoviesCubit extends HydratedCubit<MoviesState> {
  MoviesCubit(this._repository) : super(MoviesInitial());
  final MoviesRepository _repository;
  List<Movie> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _showingFavorites = false;

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

  Future<void> toggleFavorite(Movie movie) async {
    movie.isFavorite = !movie.isFavorite;

    if (state is MoviesLoaded) {
      if (_showingFavorites) {
        // When showing favorites, only show favorite movies
        emit(MoviesLoaded(getFavorites(), isShowingFavorites: true));
      } else {
        // When showing all movies, maintain the full list
        emit(MoviesLoaded(_movies, isShowingFavorites: false));
      }
    } else if (state is MoviesOffline) {
      emit(MoviesOffline(getFavorites()));
    }
  }

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

  List<Movie> getFavorites() {
    return _movies.where((movie) => movie.isFavorite).toList();
  }

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
