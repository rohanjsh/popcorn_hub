import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';
import 'package:popcorn_hub/feature/movies/repository/movies_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._moviesRepository) : super(const SearchInitial());

  final MoviesRepository _moviesRepository;

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

  void clearSearch() {
    emit(const SearchInitial());
  }
}
