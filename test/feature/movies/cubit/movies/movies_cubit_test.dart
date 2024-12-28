import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:popcorn_hub/feature/movies/cubit/movies/movies_cubit.dart';
import 'package:popcorn_hub/feature/movies/models/movie.dart';
import 'package:popcorn_hub/feature/movies/repository/movies_repository.dart';

class MockMoviesRepository extends Mock implements MoviesRepository {}

class MockMoviesCubit extends MockCubit<MoviesState> implements MoviesCubit {
  @override
  Map<String, dynamic>? toJson(MoviesState state) => null;

  @override
  MoviesState? fromJson(Map<String, dynamic> json) => null;
}

// Create a mock for HydratedStorage
class MockHydratedStorage extends Mock implements Storage {
  @override
  dynamic read(String? key) => null;

  @override
  Future<void> write(String? key, dynamic value) async {}

  @override
  Future<void> delete(String? key) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  late MockMoviesRepository mockRepository;
  late Storage storage;

  setUpAll(() {
    registerFallbackValue(MoviesInitial());
    storage = MockHydratedStorage();
    HydratedBloc.storage = storage;
  });

  setUp(() {
    mockRepository = MockMoviesRepository();
  });

  final testMovies = [
    Movie(
      id: 1,
      title: 'Test Movie 1',
      overview: 'Overview 1',
      posterPath: '/poster1.jpg',
    ),
    Movie(
      id: 2,
      title: 'Test Movie 2',
      overview: 'Overview 2',
      posterPath: '/poster2.jpg',
    ),
  ];

  group('MoviesCubit', () {
    test('initial state is MoviesInitial', () {
      expect(MoviesCubit(mockRepository).state, isA<MoviesInitial>());
    });

    blocTest<MoviesCubit, MoviesState>(
      'emits [MoviesLoading, MoviesLoaded] when loadMovies is successful',
      build: () {
        when(() => mockRepository.getTrendingMovies(any()))
            .thenAnswer((_) async => testMovies);
        return MoviesCubit(mockRepository);
      },
      act: (cubit) => cubit.loadMovies(),
      expect: () => [
        isA<MoviesLoading>(),
        isA<MoviesLoaded>()
            .having((s) => s.movies.length, 'movies length', testMovies.length),
      ],
    );

    blocTest<MoviesCubit, MoviesState>(
      'emits [MoviesLoading, MoviesOffline] when loadMovies fails',
      build: () {
        when(() => mockRepository.getTrendingMovies(any()))
            .thenThrow(Exception('Network error'));
        return MoviesCubit(mockRepository);
      },
      act: (cubit) => cubit.loadMovies(),
      expect: () => [
        isA<MoviesLoading>(),
        isA<MoviesOffline>()
            .having((s) => s.favoriteMovies.length, 'favorites length', 0),
      ],
    );

    blocTest<MoviesCubit, MoviesState>(
      'loadMore appends new movies to existing list',
      build: () {
        when(() => mockRepository.getTrendingMovies(1))
            .thenAnswer((_) async => testMovies);
        when(() => mockRepository.getTrendingMovies(2)).thenAnswer(
          (_) async => [
            Movie(
              id: 3,
              title: 'Test Movie 3',
              overview: 'Overview 3',
              posterPath: '/poster3.jpg',
            ),
          ],
        );
        return MoviesCubit(mockRepository);
      },
      seed: () => MoviesLoaded(testMovies),
      act: (cubit) async {
        await cubit.loadMovies(); // Load initial movies first
        await cubit.loadMore(); // Then load more
      },
      expect: () => [
        isA<MoviesLoading>(),
        isA<MoviesLoaded>().having((s) => s.movies.length, 'movies length', 2),
        isA<MoviesLoaded>().having((s) => s.movies.length, 'movies length', 3),
      ],
    );
  });
}
