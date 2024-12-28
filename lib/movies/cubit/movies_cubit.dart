import 'package:connectivity_plus/connectivity_plus.dart';
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
  bool _showingFavorites = false;

  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }

  @override
  MoviesState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['movies'] != null) {
        _movies = (json['movies'] as List)
            .map((m) => Movie.fromJson(m as Map<String, dynamic>))
            .toList();

        // Restore favorites state
        if (json['favorites'] != null) {
          final favoriteIds = List<int>.from(json['favorites'] as List);
          for (final movie in _movies) {
            movie.isFavorite = favoriteIds.contains(movie.id);
          }
        }

        return MoviesLoaded(_movies, isShowingFavorites: _showingFavorites);
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
      final isOnline = await _checkConnectivity();
      if (!isOnline) {
        final favorites = getFavorites();
        // Load from cached data if available
        if (favorites.isEmpty && _movies.isEmpty) {
          final cached = fromJson(toJson(state) ?? {});
          if (cached != null) {
            emit(MoviesOffline(getFavorites()));
            return;
          }
        }
        emit(MoviesOffline(favorites));
        return;
      }

      _currentPage = 1; // Reset page when loading fresh
      emit(MoviesLoading());
      final newMovies = await _repository.getTrendingMovies(_currentPage);

      // Preserve favorite status for existing movies
      final existingFavorites = getFavorites();
      for (final movie in newMovies) {
        movie.isFavorite =
            existingFavorites.any((favMovie) => favMovie.id == movie.id);
      }

      _movies = newMovies;
      emit(MoviesLoaded(_movies, isShowingFavorites: _showingFavorites));
    } catch (e) {
      emit(MoviesError('Failed to load movies'));
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    movie.isFavorite = !movie.isFavorite;

    if (state is MoviesLoaded) {
      emit(MoviesLoaded(_movies, isShowingFavorites: _showingFavorites));
    } else if (state is MoviesOffline) {
      emit(MoviesOffline(getFavorites()));
    }
    // Force save to storage
    emit(state);
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

  List<Movie> getFavorites() {
    return _movies.where((movie) => movie.isFavorite).toList();
  }

  void toggleFavoriteFilter() {
    _showingFavorites = !_showingFavorites;
    if (_showingFavorites) {
      emit(MoviesLoaded(getFavorites(), isShowingFavorites: true));
    } else {
      emit(MoviesLoaded(_movies, isShowingFavorites: false));
    }
  }
}
